/* this function  given a marker file and a consensus file, count read numbers for alleles at markers */
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include  <fstream>
#include <iostream>
#include  <sstream>
#include   <vector>
#include      <map>
#include   <time.h>
#include <assert.h>

#include "split_string.h"

struct ALLELE
{
    string   p1; // parent1      allele: Introgressed to
    int    cnt1;
    string   p2; // parent2 allele: background of IL
    int    cnt2;
};

//
bool read_marker(string marker_file, map<string, ALLELE>* markers); // not used
//
bool read_marker2(string marker_file, map<string, ALLELE>* markers);
bool read_consensus(string consensus_file, map<string, ALLELE>* markers);
bool output_counts_at_markers(map<string, ALLELE> markers, string outprefix);


int main(int argc, char* argv[])
{
    // g++ marker_allele_count.cpp split_string.cpp -O3 -o marker_allele_count
    if(argc < 4)
    {
        printf("\nGiven snp marker and coverage files, this function count reads covering two parental alleles.\n");
        const char *buildString = __DATE__ ", " __TIME__ ".";
        cout << "(compiled on " << buildString << ")" << endl;        
        printf("Usage: marker_allele_count markers.txt consensus.txt outprefix\n");
        exit(1);
    }
    // get files
    double startT=clock();
    
    // step 1: read allele of parent 1: parent2 alleles
    string p1file = (string)argv[1];
    map<string, ALLELE> markers;
    if(!read_marker2(p1file, &markers))
    {
        cout << "   Error: reading parent 1 alleles failed. " << endl;
        return false;
    }
    
    // step 2: read consensus and count parent1 vs. parent2 alleles
    string consensus_file=(string)argv[2];
    if(!read_consensus(consensus_file, &markers))
    {
        cout << "   Error: reading consensus file " << consensus_file << " failed. " << endl;
        return false;        
    }
    
    // step 3: output allele counts at markers
    string outprefix=(string)argv[3];
    if(!output_counts_at_markers(markers, outprefix))
    {
        cout << "   Error: writing count file failed. " << endl;
        return false;        
    }
    
    //
    time_t ftime;
    struct tm* tinfo;
    time(&ftime);
    tinfo = localtime(&ftime);
    printf("\nCounting alleles successfully finished on %s\n", asctime(tinfo));
    return 0;
}

bool output_counts_at_markers(map<string, ALLELE> markers, string outprefix)
{
    string ofilename = outprefix + "_allele_cnts_at_markers.txt";
    ofstream ofp;
    ofp.open(ofilename.c_str(), ios::out);
    if(!ofp.good())
    {
        cout << "   Error: cannot open file " << ofilename << " write allele counts." << endl;
        return false;
    }
    
    // chr1H	557378	C	-1	A	-1
    ofp << "#chr\tpos\tp1(Col)\tp1_cnt\tp2(Ler)\tp2_cnt" << endl;
    
    int num_discarded = 0;
    
    map<string, ALLELE>::iterator mkritr;
    map<string, ALLELE>::iterator mkritr_end;
    mkritr     = markers.begin();
    mkritr_end = markers.end();
    while(mkritr != mkritr_end)
    {
        ALLELE tmp = (*mkritr).second;
        if(tmp.cnt1!=-1 && tmp.cnt2!=-1)
        {
            // chr pos parent1 parent2 cnt_parent1 cnt_parent2
            ofp << (*mkritr).first << "\t" 
                << tmp.p1          << "\t"
                << tmp.cnt1        << "\t"
                << tmp.p2          << "\t"
                << tmp.cnt2        << endl;
        //
        }
        else
        {
            num_discarded ++;
        }
        mkritr ++;
    }
    ofp.close();
    
    cout << "   Info: total " << markers.size() << " markers; " << num_discarded << " discarded. " << endl;
    cout << "         you may want to sort the output: sort -k1,1 -k2,2n " << ofilename << endl;
    
    return true;
}

bool read_consensus(string consensus_file, map<string, ALLELE>* markers)
{
    ifstream ifp;    
    ifp.open(consensus_file.c_str(), ios::in);
    if(!ifp.good())
    {
        cout << "   Error: cannot open file " << consensus_file << endl;
        return false;
    }    
    
    int low_freq_num = 0;
    
    while(ifp.good())
    {
        string line("");
        getline(ifp, line);
        if(line.size()==0 || line[0]=='#') continue;
        
        // chr1H	1609376	C	12	A:0	C:10	G:0	T:0	D:0	N:2	1
        vector<string> lineinfo = split_string(line, '\t');
        
        string key = lineinfo[0].substr(3) + "\t" + lineinfo[1];
        
        if( (*markers).find(key) != (*markers).end() )
        {     
            // base call of sample at this position      
            string alt=lineinfo[2];
            int cnt=0;
            //
            int allcnt = atoi(lineinfo[3].c_str());            
            int cntA = atoi(lineinfo[4].c_str());
            int cntC = atoi(lineinfo[5].c_str());
            int cntG = atoi(lineinfo[6].c_str());
            int cntT = atoi(lineinfo[7].c_str());
            
            if(alt.compare("A") == 0)
            {
                cnt = cntA;
            }
            else
            if(alt.compare("C") == 0)
            {
                cnt = cntC;
            }                        
            else
            if(alt.compare("G") == 0)
            {
                cnt = cntG;
            }
            else
            if(alt.compare("T") == 0)
            {
                cnt = cntT;
            }
            else ;          
            
            //if ((double)cnt/(double)allcnt < 0.8)
            if (0)
            {
                if(low_freq_num == 0)
                {
                   cout << "\n   Warning: allele freq " << (double)cnt/(double)allcnt << " <0.8 at " << key << endl;
                   cout << "            such positions will be skipped - total skipping given in the end. "  << endl;
                }
                low_freq_num ++;
            }
            else
            {
                if( ((*markers)[key].p1).compare(alt) == 0 )
                {
                    // parent1 allele
                    (*markers)[key].cnt1 = cnt;
                    
                    // parent2 allele
                    if(((*markers)[key].p2).compare("A") == 0)
                    {
                        (*markers)[key].cnt2 = cntA;
                    }
                    else
                    if(((*markers)[key].p2).compare("C") == 0)
                    {
                        (*markers)[key].cnt2 = cntC;
                    }
                    else
                    if(((*markers)[key].p2).compare("G") == 0)
                    {
                        (*markers)[key].cnt2 = cntG;                    
                    }
                    else
                    if(((*markers)[key].p2).compare("T") == 0)
                    {
                        (*markers)[key].cnt2 = cntT;
                    }
                    else ;                                                            
                }
                else
                if( ((*markers)[key].p2).compare(alt) == 0 )
                {
                    // parent2 allele
                    (*markers)[key].cnt2 = cnt;
                   
                    // parent1 allele
                    if(((*markers)[key].p1).compare("A") == 0)
                    {
                        (*markers)[key].cnt1 = cntA;
                    }
                    else
                    if(((*markers)[key].p1).compare("C") == 0)
                    {
                        (*markers)[key].cnt1 = cntC;
                    }
                    else
                    if(((*markers)[key].p1).compare("G") == 0)
                    {
                        (*markers)[key].cnt1 = cntG;                    
                    }
                    else
                    if(((*markers)[key].p1).compare("T") == 0)
                    {
                        (*markers)[key].cnt1 = cntT;
                    }
                    else ;                     
                }
            }
        }
                    
    }    
    ifp.close();
    
    return true;
}

bool read_marker(string marker_file, map<string, ALLELE>* markers)
{
    ifstream ifp;
    ifp.open(marker_file.c_str(), ios::in);
    if(!ifp.good())
    {
        cout << "   Error: cannot open file " << marker_file << endl;
        return false;
    }
    while(ifp.good())
    {
        string line("");
        getline(ifp, line);
        if(line.size()==0 || line[0]=='#') continue;
        
        //  proj_1_alt0	chr1H	287990	ref:C	alt:T	68.5	4	1.0000	1
        vector<string> lineinfo = split_string(line, '\t');
        
        if(lineinfo[3].compare("N") == 0 ||
          lineinfo[4].compare("N")  == 0) continue;
        
        //
        string key = lineinfo[1] + "\t" + lineinfo[2]; // "chr\tpos"
        ALLELE tmp;
        tmp.p1   = lineinfo[3]; // parent1  allele      
        tmp.p2   = lineinfo[4]; // parent2 allele    
        tmp.cnt1 = -1;          // parent1 cnt
        tmp.cnt2 = -1;          // parent2 cnt
        //
        assert((*markers).find(key) == (*markers).end());
        //
        (*markers).insert(std::pair<string, ALLELE>(key, tmp));
    }
    ifp.close();
    return true;
}


bool read_marker2(string marker_file, map<string, ALLELE>* markers)
{
    ifstream ifp;
    ifp.open(marker_file.c_str(), ios::in);
    if(!ifp.good())
    {
        cout << "   Error: cannot open file " << marker_file << endl;
        return false;
    }
    while(ifp.good())
    {
        string line("");
        getline(ifp, line);
        if(line.size()==0 || line[0]=='#') continue;
        
        //  proj_1_alt0	chr1H	287990	ref:C	alt:T	68.5	4	1.0000	1
        vector<string> lineinfo = split_string(line, '\t');
        
        if(lineinfo[3].compare("N") == 0 ||
          lineinfo[4].compare("N")  == 0) continue;
        
        //
        string key = lineinfo[1] + "\t" + lineinfo[2]; // "chr\tpos"
        ALLELE tmp;
        
        //
        if(1)
        {
            tmp.p1   = lineinfo[3]; // parent1  allele      
            tmp.p2   = lineinfo[4]; // parent2 allele    
            tmp.cnt1 = -1;          // parent1 cnt
            tmp.cnt2 = -1;          // parent2 cnt
        }
        /* // do not swap the alleles: as markers created by shoremap create always keep parent1 allele at the 4th column; alternative allele at the 5th column
        else
        {
            tmp.p1   = lineinfo[4]; // parent1  allele      
            tmp.p2   = lineinfo[3]; // parent2 allele    
            tmp.cnt1 = -1;          // parent1 cnt
            tmp.cnt2 = -1;          // parent2 cnt            
        }
        */
        //
        assert((*markers).find(key) == (*markers).end());
        //
        (*markers).insert(std::pair<string, ALLELE>(key, tmp));
    }
    ifp.close();
    return true;
}
