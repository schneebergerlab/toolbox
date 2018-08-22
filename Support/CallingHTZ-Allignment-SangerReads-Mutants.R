# 15.06.2018 Extracting HTZ calls from Sanger sequencing. Loop for different samples over several candidate mutations #
## This script creates chromatographs from .ab1 files (Sanger) with heterozygous calls. Also it creates a Clustal-Wallis allignment (msa package) with the reference

########### y = makeBaseCalls(y, ratio = 0.01) ##################
# Ratio provides the threshold to call the minor variant in the chromatograph. Ratio = 0.33 used to be the predefined value.



# Now we append new sequences from sangeranalyseR

## import_multiple_sanger_files_to_R
# Adapted from https://blogazonia.wordpress.com/2014/05/08/import-multiple-files-to-r/
# Purpose: Import multiple sanger files to the Global Environment in R
# list all ab1 files from the current directory matching a patern
library(seqinr)
library(sangeranalyseR)
library(sangerseqR)
library(stringr)
library(msa)
library(latexpdf)

setwd("/srv/netscratch/dep_coupland/grp_schneeberger/projects/mutation_tree/Apple/Jose/ReadingSanger/reReading/Threshold0.1/")

# Contigs refer to the candidate mutations. HQ provided contigs having the mutation in the center of the sequence.
ls.contigs <- list("169395","86445","73519","73045","70184","67102","66618","55839","55541","52092","44842","44095","44093","38103","37991","36869","35959","33189","31473","29360","27387","25711","23019","21491","20799","20587","20119","16917","15327","15087","14393","13787","12691","12199","11153","10851","10473","10005","8965","8047","7726","7218","6517","5763","5501","5351","4941","4041","3993","3831","3723","3533","3117","3113","3018","2910","2884","2844","1690","1186","1168","1046","270","0218","212","88","74","34","14")	


# Manish's alternative to for loop (much faster).
ls.files<-list()
ls.files <- lapply(ls.contigs, function(x){
  list.files(pattern = paste(x,".ab1$",sep=""));
})

# Adding the names
names(ls.files) <- lapply(ls.contigs, function(x){
  x
})


# Manish code to nested lapply, to use sangerseq in a list (mutations) of lists (samples)  
myAbifs <- lapply(ls.files, function(x){
  lapply(x, function(y){
    y = sangerseq(sangerseqR::read.abif(y))
  })
})

# No need to recopy all ab1 files to the same folder we will put the output. So we change the working directory:
setwd("/srv/netscratch/dep_coupland/grp_schneeberger/projects/mutation_tree/Apple/Jose/ReadingSanger/reReading/Threshold0.01/")
myAbifs[[1]][1]$M1.169395.ab1
length(myAbifs)
# Drawing RAW chromatographs
for(i in 1:length(myAbifs)){
  names(myAbifs[[i]]) <- ls.files[[i]]
}

# Check the different access to elements using [ or [[ . First, one element (list of 21 elements--> ab1 for each sample); second, the content of the list (21 elements).
length(myAbifs[1])
length(myAbifs[[1]])

lapply(myAbifs, function(x){
  mynames <- names(x)
  lapply(mynames, function(y){
    y = chromatogram(x[[y]],
                     trim5 = 0,
                     trim3 = 0,
                     showcalls = c("primary", "secondary", "both", "none"),
                     width = 74,
                     height = 2,
                     cex.mtext = 1,
                     cex.base = 1,
                     ylim = 2,
                     filename = paste(unlist(strsplit(y,"[.]"))[[2]],
                                      unlist(strsplit(y,"[.]"))[[1]],
                                      "RAWchrom",
                                      sep='.'),

                     showtrim = T,
                     showhets = TRUE)
  })
})


# Rename myAbifs with the ls.files names
for(i in 1:length(myAbifs)){
  names(myAbifs[[i]]) <- ls.files[[i]]
}
head(myAbifs)
# MakeBaseCalls to get the (Htz) sequences

myBaseCalls <- lapply(myAbifs, function(x){
  lapply(x, function(y){
    y = makeBaseCalls(y, ratio = 0.01)
  })
})
length(myBaseCalls)
names(myBaseCalls[[1]])
names(myBaseCalls[[1]][[1]])

names(myBaseCalls[64])
myBaseCalls[64]$`0218`$M57L.00218.ab1@traceMatrix
myBaseCalls[64]$`0218`$M57L.00218.ab1@peakPosMatrix
# Creation of the chromatogram after BaseCall
lapply(myBaseCalls, function(x){
  finNames <- names(x)
  lapply(finNames, function(y){
    # names(y)
    chromatogram(x[[y]], trim5 = 0,
                 trim3 = 0,
                 showcalls = c("primary","secondary", "both", "none"),
                 width = 74,
                 height = 2, 
                 cex.mtext = 1, 
                 cex.base = 1, ylim = 2, 
                 filename = paste(unlist(strsplit(y,"[.]"))[[2]], 
                                  unlist(strsplit(y,"[.]"))[[1]],
                                  "BASECallchrom", 
                                  sep='.'),
                 showtrim = T,
                 showhets = TRUE)
  })
})

unlist(strsplit('M1.169395.ab1',"[.]"))[[2]]


# Create files 69 files with lapply. appending sequences to existing Fasta   

myBaseCalls[[1]]
finNames <- names(myBaseCalls)
lapply(finNames, function(x){
  finNames1 <- names(myBaseCalls[[x]])
  lapply(finNames1, function(y){
    write.fasta(toString(myBaseCalls[[x]][[y]]@primarySeq),
                paste(y,".PBAS1", sep=''),
                file.out = paste(x,".fa", sep=''),
                open = "a", as.string= F)
  })
})

# And for the PBAS2 sequence
lapply(finNames, function(x){
  finNames1 <- names(myBaseCalls[[x]])
  lapply(finNames1, function(y){
    write.fasta(toString(myBaseCalls[[x]][[y]]@secondarySeq),
                paste(y,".PBAS2", sep=''),
                file.out = paste(x,".fa", sep=''),
                open = "a", as.string= F)
  })
})



# Collection of all files .fa

ls.fastaSangIllu <- list.files(pattern = ".fa$")

for (i in ls.fastaSangIllu){
  myseq <- readDNAStringSet(i, format = "FASTA")
  myseqPermuted <- order(names(myseq))
  mymsa <- msa(myseq[myseqPermuted], "ClustalW", order = "input")
  msaPrettyPrint(mymsa,
                 #skForOverwrite=FALSE, 
                 output="pdf", 
                 showNames="left",
                 file = paste0(strsplit(i,".fa")[[1]],".pdf"),
                 verbose=FALSE,
                 showLogo="none",
                 showLegend = F, 
                 consensusColor="ColdHot",
                 #verbose=FALSE, 
                 #code=paste0("\\orderseqs{1-", nrow(mymsa), "}"), 
                 furtherCode = "\\showruler{1}{top}")
  }






