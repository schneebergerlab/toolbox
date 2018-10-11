// separate seqs in a fasta file into different files named by Chrseqname.fa

#include  <stdio.h>
#include <stdlib.h>
#include <string.h>
#include  <fstream>
#include <iostream>
#include  <sstream>
#include <map>
#include <vector>

#include "split_string.h"

using namespace std;

int main(int argc, char* argv[])
{
    // g++ fasta_separator.cpp -o fasta_separator -O3
    if(argc < 2) {printf("Usage: fasta_separator seq.fa\n"); return false;}
    std::string genome_file = argv[1];

    // open input fasta to read sequences
    std::ifstream infp (genome_file.c_str());
    if(!infp.is_open())
    {
        printf("Cannot open file \'%s\' to read sequences in fasta format. Exited.\n", genome_file.c_str());
        exit(1);
    }
    printf("Reading sequence info from file:\t%s...\n", genome_file.c_str());
    
    // traverse input fasta file
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
            string seq_name = line;
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
                if(seq_line_id > 1) seq += '\n';
                seq    += chrseq;
            }
            // output this seq to the file
            string ofilename("");
            ofilename = "chr" + seq_name.substr(1) + ".fa";
            std::ofstream ofp;
            ofp.open(ofilename.c_str(), std::ios::out);
            ofp << seq_name << endl;
            if(seq.size()>80 && seq.substr(0, seq.size()-1).find("\n")==std::string::npos)
            {
                int ln = seq.size()/80;
                int rm = seq.size()%80;
                
                for(int oi=0; oi < ln; oi ++)
                {
                    ofp << seq.substr(oi*80, 80);
                    ofp << '\n';
                }
                if(rm > 0)
                {
                    ofp << seq.substr(ln*80);
                    ofp << endl;
                }
            }
            else
            {
                ofp << seq << endl;
            }
            ofp.close();
            total_seq_selected ++;
        }
        else
        {
            getline(infp, line);
        }
    }
    cout << "   Info: total number of sequences in give fasta: " << total_seq_num      << endl;
    cout << "         total number of sequences selected:      " << total_seq_selected << endl;
    infp.close();
}
