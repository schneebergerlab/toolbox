#!/usr/bin/env python
# encoding: utf-8


import re
import sys
import os
import glob
import getopt
import pysam


def main(argv):
    indir = ""
    
    ver = ""
    genome = ""
    try:
        opts, args = getopt.getopt(argv,"i:v:",["indir=","ver="]) 
    except getopt.GetoptError:
        print 'gene.id.update.py -i <indir> -v <ver> '
        sys.exit(2)
    if len(opts) == 0 :
        print 'gene.id.update.py -i <indir> -v <ver> '
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            print 'gene.id.update.py -i <indir> -v <ver> '
            sys.exit()
        elif opt in ("-i", "--indir"):
            indir = arg              
        elif opt in ("-o", "--outdir"):
            outdir = arg
        elif opt in ("-v", "--ver"):
            ver = arg
        
#outdir/syntenic.cluster.txt            
#outdir/rearranged.cluster.txt
#outdir/rearranged.cluster.col.genes.txt
#outdir/rearranged.cluster.col.prot.genes.txt
#outdir/rearranged.cluster.col.prot.genes.vs.AMPRIL.txt

    
    #accs = ["An-1","C24","Cvi","Eri","Kyo","Ler","Sha"]
    #accs = ["An-1","C24","Cvi","Eri"]
    accs = ["Kyo","Ler","Sha"]
    #accs = ["Sha"]
    #pres = ["AN1","C24","CVI","ERI","KYO","LER","SHA"]
    #pres = ["AN1","C24","CVI","ERI"]
    pres = ["KYO","LER","SHA"]
    #pres = ["SHA"]
    for i in range(len(accs)) :
        acc = accs[i]
        geneFile = indir + "/" + acc + "/repeat/TErelated/annotation.genes.TE.gff"         
        fi = open(geneFile,"r")
        genes1 = {}  ##chr1-5
        genesStart1 = {}
        genes2 = {} ## unachored
        genesStart2 = {}
        id = ""        
        while True :
            line = fi.readline()
            if not line : break
            t = line.strip().split()                            
            if t[2] == "gene" :
                id = t[8].split(";")[0]
                id = id.split("=")[1]
                if re.search("chr", line) :                
                    if not genes1.has_key(t[0]) :
                        genes1[t[0]] = {}
                        genes1[t[0]][id] = line
                        genesStart1[t[0]]={}
                        genesStart1[t[0]][id] = t[3]
                    else :                
                        genes1[t[0]][id] = line
                        genesStart1[t[0]][id] = t[3]
                else :
                    if not genes2.has_key(t[0]) :
                        genes2[t[0]] = {}
                        genes2[t[0]][id] = line
                        genesStart2[t[0]] = {}
                        genesStart2[t[0]][id] = t[3]
                    else :                
                        genes2[t[0]][id] = line
                        genesStart2[t[0]][id] = t[3]
            else :                    
                if re.search("chr",line) :
                    if not genes1[t[0]].has_key(id) : 
                        print line
                        sys.exit()                    
                    genes1[t[0]][id] = genes1[t[0]][id] + line
                else :
                    genes2[t[0]][id] = genes2[t[0]][id] + line
                
        fi.close()
        
        geneFile = indir + "/" + acc + "/noncoding/InfernalRfam/noncoding.gene.gff3"         
        fi = open(geneFile,"r")        
        while True :
            line = fi.readline()
            if not line : break
            t = line.strip().split()                            
            id = t[8].split(";")[0]
            id = id.split("=")[1]
            if re.search("chr", line) :                
                if not genes1.has_key(t[0]) :
                    genes1[t[0]] = {}
                    genes1[t[0]][id] = line
                    genesStart1[t[0]] = {}
                    genesStart1[t[0]][id] = t[3]
                else :                
                    genes1[t[0]][id] = line
                    genesStart1[t[0]][id] = t[3]
            else :
                if not genes2.has_key(t[0]) :
                    genes2[t[0]] = {}
                    genes2[t[0]][id] = line
                    genesStart2[t[0]] = {}
                    genesStart2[t[0]][id] = t[3]
                else :                
                    genes2[t[0]][id] = line
                    genesStart2[t[0]][id] = t[3]
            
        fi.close()
        
        tmpFile = indir + "/" + acc + "/version2/" + ver + ".genes.tmp.gff"
        fo = open(tmpFile,"w")
        for chrom in sorted(genes1.keys()) :
            genes = genes1[chrom]    
            geneStart = genesStart1[chrom]
            for k in sorted(geneStart.items(), key=lambda x: int(x[1])) :
                id = k[0]
                #print k
                #sys.exit()
                
                lines = genes1[chrom][id]
                fo.write(lines)
        
        for chrom in sorted(genes2.keys()) :
            genes = genes2[chrom]    
            geneStart = genesStart2[chrom]
            for k in sorted(geneStart.items(), key=lambda x: int(x[1])) :
                id = k[0]
                lines = genes2[chrom][id]
                fo.write(lines)                
        fo.close()
        
        fi = open(tmpFile,"r")
        outFile1 = indir + "/" + acc + "/version2/" + acc + ".genes.annotation." + ver +".gff"
        outFile2 = indir + "/" + acc + "/version2/" + acc + ".protein-coding.genes."+ ver +".gff"
        fo1 = open(outFile1,"w")
        fo2 = open(outFile2,"w")
        gID = ""
        mID = 0
        chrom = ""
        idx = 10010
        pre = pres[i]
        cdsID = 0
        flag = "prot"
        while True :
            line = fi.readline()
            if not line : break
            t = line.strip().split()
            if not re.search("chr",t[0]) :
                fo1.write(line)
                if t[2] == "gene" :
                    note = t[8].split(";")[-1]
                    note = note.split("=")[1]
                    if re.search("protein",note) : 
                        flag = "prot"
                    else :
                        flag = "TE" 
                if flag == "prot" : 
                    if not re.search("Infer",t[1]) : 
                        fo2.write(line)    
                continue
           
            if re.search("Infer",t[1]) :
                if not chrom :
                   chrom = t[0][3]
                   idx = 10010
                elif chrom != t[0][3] :
                    chrom = t[0][3]
                    idx = 10010
                else :
                    idx += 10
                infor = "ID=AT" + pre + "-" + chrom + "G" + str(idx)
                infor = infor + ";Note=" + t[2]
                outline ="\t".join(t[0:8]) + "\t" + infor + "\n"
                fo1.write(outline)  
            else :
                
                if t[2] == "gene" :
                    note = t[8].split(";")[-1]
                    note = note.split("=")[1]
                    if re.search("protein",note) : 
                        flag = "prot"
                    else :
                        flag = "TE"
                    if not chrom :
                       chrom = t[0][3]
                       idx = 10010
                    elif chrom != t[0][3] :
                        chrom = t[0][3]
                        idx = 10010
                    else :
                        idx += 10
                    infor = "ID=AT" + pre + "-" + chrom + "G" + str(idx)
                    infor = infor + ";Note=" + note 
                    mID = 0
                elif t[2] == "mRNA" :
                    mID += 1
                    infor = "ID=AT" + pre + "-" + chrom + "G" + str(idx) + "." + str(mID) + ";Parent=AT" + pre + "-" + chrom + "G" + str(idx)
                    cdsID = 0
                elif t[2] =="exon" :
                    nn = t[8].split(";")[0]
                    nn = nn.split("=")[1]
                    tt = nn.split(".")
                    mm = tt[-1]
                    infor = "ID=AT" + pre + "-" + chrom + "G" + str(idx) + "." + str(mID) + "." + mm 
                    infor = infor + ";Parent=AT" + pre + "-" + chrom + "G" + str(idx) + "." + str(mID)
                elif t[2] =="CDS" :
                    cdsID += 1
                    infor = "ID=AT" + pre + "-" + chrom + "G" + str(idx) + "." + str(mID) +  ".cds" + str(cdsID) 
                    infor = infor + ";Parent=AT" + pre + "-" + chrom + "G" + str(idx) + "." + str(mID)                    
                outline ="\t".join(t[0:8]) + "\t" + infor + "\n"
                fo1.write(outline)  
                if flag == "prot" : fo2.write(outline)                        
        fi.close()
        fo1.close()
        fo2.close()
        
        
        ProtFas = os.path.join(indir,acc,"version2", acc + "." + ver + ".protein.fasta")
        CDSFas = os.path.join(indir,acc,"version2", acc + "." + ver + ".CDS.fasta")
        cDNAFas = os.path.join(indir,acc,"version2", acc + "." + ver + ".cDNA.fasta")
        GeneFas = os.path.join(indir,acc,"version2", acc + "." + ver + ".gene.fasta")
        genome = os.path.join(indir,acc,"reference","chr.all.v2.0.fasta")
        EVM_Utils = "/projects/dep_coupland/grp_schneeberger/bin/EVM_r2012-06-25/EvmUtils"
        cmd = EVM_Utils + "/gff3_file_to_proteins.pl " + outFile2  + " " + genome + " prot > " + ProtFas
        os.system(cmd)
        cmd = EVM_Utils + "/gff3_file_to_proteins.pl " + outFile2  + " " + genome + " CDS > " + CDSFas
        os.system(cmd)
        cmd = EVM_Utils + "/gff3_file_to_proteins.pl " + outFile2  + " " + genome + " cDNA > " + cDNAFas
        os.system(cmd)
        cmd = EVM_Utils + "/gff3_file_to_proteins.pl " + outFile2  + " " + genome + " gene > " + GeneFas
        os.system(cmd)
        

if __name__ == "__main__":
   main(sys.argv[1:])  
   
   