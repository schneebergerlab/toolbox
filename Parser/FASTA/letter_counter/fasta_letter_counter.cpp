#include   <string>
#include   <vector>
#include <iostream>
#include <fstream>
#include <algorithm>
using namespace std;
//
int main(int argc, char* argv[])
{
    if(argc < 3)
    {
        // g++ fasta_letter_counter.cpp -O3 -o fasta_letter_counter
        cout << "\nFunction: given a fasta, count occurrence of a specific letter X";
        const char *buildString = __DATE__ ", " __TIME__ ".";
        cout << "(compiled on " << buildString << ")"    << endl;
        cout << "\nUsage: fasta_letter_counter .fasta LETTER" << endl;
        cout << "Note: LETTER must be in upper case. \n" << endl;
        return 1;
    }
    string fasfile = (string)argv[1];
    std::ifstream fp(fasfile.c_str());
    if(!fp.is_open())
    {
        cout << "Cannot open file " << fasfile << " to read sequences, exited!" << endl;
        return 1;
    }
    string letter = (string)argv[2];    
    unsigned long total_length = 0;
    long totanum = 0;
    string line("");
    getline(fp, line);
    while(fp.good())
    {
        if(line.size()==0) continue;
        if(line[0]=='>')
        {
            string seq("");
            string seqtmp("");
            getline(fp, seqtmp);
            long thisnum = 0;
            while(fp.good() && seqtmp[0] != '>')
            {
                std::transform(seqtmp.begin(), seqtmp.end(), seqtmp.begin(), ::toupper);
                seq += seqtmp;
                seqtmp.clear();
                getline(fp, seqtmp);
            }
            cout << "    length of " << line.substr(1) << ": " << seq.size() << "; "; 
            thisnum     = std::count(seq.begin(), seq.end(), letter[0]);
            totanum    += thisnum;
            cout << "number of " << letter << ": " << thisnum << endl;
            total_length += seq.length();
            line = seqtmp;
        }
    }
    fp.close();
    cout << "    total length of all sequences: " << total_length << endl;
    cout << "   Total number of " << argv[2] << " is: " << totanum << endl;
    return 0;
}
