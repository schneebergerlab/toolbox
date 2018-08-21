args <- commandArgs()

pdf(file="plot_insert_size_dist.pdf", width=12, height=12)

########## Read in files ############

print(args[5])
print(args[6])
print(args[7])

sizedist<-read.table(args[5])
minimal<-as.integer(args[6])
maximal<-as.integer(args[7])



################ Layout for the first slide #########################################

layoutmat<-matrix(data=c(1), nrow=1, ncol=1)
layout(layoutmat)

#####################################################################################
print(minimal)
print(maximal)


hist(sizedist$V1, breaks=100000, col="black", xlim=c(minimal, maximal))



# Thanks for flying with R, enjoy your stay in the world of colorful R plots and good-bye:

dev.off()

