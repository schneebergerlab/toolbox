# Read in command line options
args <- commandArgs()
shape<-as.numeric(args[5])
scale<-as.numeric(args[6])

options(scipen=999999999)
out<-rgamma(1, shape, scale=scale)
write(out, file = "gammad.txt", append = FALSE, sep = " ")

