// given a fasta file, and a bed file, calculate GC content for windows in bed file

#include   <stdio.h>
#include  <stdlib.h>
#include  <string.h>
#include   <fstream>
#include  <iostream>
#include   <sstream>
#include       <map>
#include    <vector>
#include <algorithm>
#include "split_string.h"

using namespace std;

bool read_bed(string bedfile, map<string, multimap<unsigned long, unsigned long> >* windows);

int main(int argc, char* argv[])
{
    // g++ GC_calculator.cpp -o GC_calculator -O3
    if(argc < 3)
    {
        cout << "\nFunction: given a fasta and a bed, calculate GC content within seq-windows defined in bed ";
        const char *buildString = __DATE__ ", " __TIME__ "";
        cout << "(compiled on " << buildString << ")."    << endl;
        cout << "\nUsage: GC_calculator genome.fasta chrWindow.bed" << endl << endl;
        return 1;    
    }
    std::string genomefile = argv[1];
    std::string bedfile    = argv[2];
    // read bed
    map<string, multimap<unsigned long, unsigned long> > windows;
    if(!(read_bed(bedfile, &windows)))
    {   
        return 1;
    }
    // prepare output file for GC collection
    vector<string> bedfileinfo = split_string(bedfile, '/');
    string ofilename = "GC_"+bedfileinfo[bedfileinfo.size()-1];
    ofstream ofp;
    ofp.open(ofilename.c_str(), ios::out);
    if(!ofp.good())
    {
        cout << "   Error: cannot open output file "       << ofilename << endl;
        return 1;
    }
    ofp << "#chr\twindow_start\twindow_end\tGC_content"    << endl;
    // open input fasta to read sequences
    std::ifstream infp (genomefile.c_str(), ios::in);
    if(!infp.is_open())
    {
        cout << "   Error:Cannot open file " << genomefile << endl;
        return 1;
    }
    cout << "   Info: reading info from fasta file... " << endl;
    // traverse input fasta file
    bool checkon = false;
    int total_seq_num      = 0;
    int total_seq_selected = 0;
    std::string line("");
    getline(infp, line);
    while(infp.good())
    {
        if(line.size()==0) 
        {
            getline(infp, line);
            continue;
        }
        if(line.find(">") != std::string::npos)
        {
            string seq_name = line.substr(1);
            total_seq_num ++;
            string seq("");
            int seq_line_id = 0;
            while(infp.good())
            {
                std::string chrseq("");                
                getline(infp, chrseq);
                if(chrseq.size()==0) continue;
                seq_line_id ++;
                line    = chrseq;
                if(line.find(">")!=std::string::npos) break; // next seq
                std::transform(chrseq.begin(), chrseq.end(), chrseq.begin(), ::toupper);
                seq    += chrseq;
            }
            // calculate gc on this chr with bed windows
            cout << "   Info: chr " << seq_name << ": " << seq.size() << " bp. " << endl;
            map<string, multimap<unsigned long, unsigned long> >::iterator chritr;
            chritr = windows.find(seq_name);
            if(chritr != windows.end())
            {
                cout << "         calculating GC..." << endl;
                multimap<unsigned long, unsigned long> tmp = (*chritr).second;
                multimap<unsigned long, unsigned long>::iterator witr;
                multimap<unsigned long, unsigned long>::iterator witr_end;
                witr     = tmp.begin();
                witr_end = tmp.end();
                while(witr != witr_end)
                {
                    unsigned long sta = (*witr).first;
                    unsigned long end = (*witr).second;
                    string wseq = seq.substr(sta-1, end-sta+1);
                    unsigned long G_cnt =  std::count(wseq.begin(), wseq.end(), 'G');
                    unsigned long C_cnt =  std::count(wseq.begin(), wseq.end(), 'C');
                    if(checkon && witr == tmp.begin())
                    {
                        cout << "   Check: "       << wseq  << endl;
                        cout << "          G_cnt=" << G_cnt << ", C_cnt=" << C_cnt << endl;
                    }
                    double GCr = (double)(G_cnt+C_cnt)/(double)wseq.size();
                    ofp << seq_name << "\t" << sta << "\t" << end << "\t" << GCr << endl;
                    witr ++;   
                }
            }
            else
            {
                cout << "         no query on this chr. " << endl;
            }
        }
        else
        {
            getline(infp, line);
        }
    }
    cout << "   Info: total number of sequences in give fasta: " << total_seq_num << endl;
    cout << "   Info: GC collected in "                          << ofilename     << endl;
    infp.close();
    ofp.close();
    return 0;
}
//
bool read_bed(string bedfile, map<string, multimap<unsigned long, unsigned long> >* windows)
{
    ifstream ifp;
    ifp.open(bedfile.c_str(), ios::in);
    if(!ifp.good())
    {
        cout << "   Error: cannot open bed file. " << endl;
        return false;
    }
    unsigned long numWin = 0;
    while(ifp.good())
    {
        string line("");
        getline(ifp, line);
        if(line.size()==0 || line[0]=='#') continue;
        vector<string> lineinfo = split_string(line, '\t'); // chr	start	end	....
        if(lineinfo.size()<3)
        {
            cout << "   Warning: skipping line " << line << endl;
            continue;
        }
        string        chr = lineinfo[0];
        unsigned long sta = strtoul(lineinfo[1].c_str(), NULL, 0);
        unsigned long end = strtoul(lineinfo[2].c_str(), NULL, 0);
        map<string, multimap<unsigned long, unsigned long> >::iterator chritr;
        chritr = (*windows).find(chr);
        if(chritr != (*windows).end())
        {
            ((*chritr).second).insert(std::pair<unsigned long, unsigned long>(sta, end));
            numWin ++;
        }
        else
        {
            multimap<unsigned long, unsigned long> tmp;
            tmp.insert(std::pair<unsigned long, unsigned long>(sta, end));
            (*windows).insert(std::pair<string, multimap<unsigned long, unsigned long> >(chr, tmp));
            numWin ++;
        }
    }
    ifp.close();
    cout << "   Info: total number of windows collected: " << numWin << endl;
    return true;
}
