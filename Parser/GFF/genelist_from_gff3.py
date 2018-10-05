#!/usr/bin/env python3
import argparse as ap


def getGenes(args):
    from pandas import read_table
    fin = read_table(args.gff.name, header = None, comment="#")
    fout = fin.loc[fin[2] == "gene",[0,3,4]]
    fout.columns = ["chr","start","end"]
    if args.n:
        info = fin.loc[fin[2] == "gene"][8]
        info = [i.split(";")[1].split("=")[1].split("_")[1] if "Name" in i.split(";")[1] else "ERROR" for i in info]
        fout["gene_name"] = info
    if args.o == None:
        print(fout)
    else:
        fout.to_csv(args.o.name,index = False, sep ="\t")
        
if __name__ == "__main__":
    parser = ap.ArgumentParser(formatter_class=ap.ArgumentDefaultsHelpFormatter)
    parser.set_defaults(func=getGenes)
    parser.add_argument("gff", help="Input .gff3 file", type = ap.FileType('r'))
    parser.add_argument("-o",help="output file name. default stdout", type = ap.FileType('w'))
    parser.add_argument("-n",help="get gene_name too", action="store_true", default= False)
    args = parser.parse_args()
    args.func(args)

