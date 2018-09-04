#!/usr/bin/env python3
import argparse as ap


def getGenes(args):
    from pandas import read_table
    fin = read_table(args.gff.name, header = None, comment="#")
    fin = fin.loc[fin[2] == "gene",[0,3,4]]
    fin.columns = ["chr","start","end"]
    if args.o == None:
        print(fin)
    else:
        fin.to_csv(args.o.name,index = False, sep ="\t")
        
if __name__ == "__main__":
    parser = ap.ArgumentParser(formatter_class=ap.ArgumentDefaultsHelpFormatter)
    parser.set_defaults(func=getGenes)
    parser.add_argument("gff", help="Input .gff3 file", type = ap.FileType('r'))
    parser.add_argument("-o",help="output file name. default stdout", type = ap.FileType('w'))    
    args = parser.parse_args()
    args.func(args)

