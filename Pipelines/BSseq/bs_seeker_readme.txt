export BSSEEKER = "/biodata/dep_coupland/grp_schneeberger/bin/BSseeker/BSseeker2-master/"

### step 1 ###  generate reference for BSseeker
$BSSEEKER/bs_seeker2-build.py -f GENOME-REF-SEQ.fa --aligner=bowtie2


### optional ####  generate smaller fastq read files, if necessary (here 5Mio reads per subset)
# read1
mkdir batch_read1
cd batch_read1
$TOOLBOX/toolbox/Parser/FASTQ/makeFastq_batch.pl reads1.fastq.gz 5000000

#read2
mkdir batch_read2
cd batch_read2
$TOOLBOX/toolbox/Parser/FASTQ/makeFastq_batch.pl reads2.fastq.gz 5000000


#### step 2 #####  align paired reads against reference using 30 threads (bt2-p 30) with 10% mismatches (-m 0.1)
python $BSSEEKER/bs_seeker2-align.py -1 batch_read1/0.fastq -2 batch_read2/0.fastq --aligner=bowtie2 -o 0.bam -f bam -m 0.1 -g GENOME-REF-SEQ.fa --bt2-p 30 --bt2--end-to-end

# or summit all at once
for i in {0..10}; do bsub -q multicore20 -o bsub_out.log -e bsub_err.log -n 10 python $BSSEEKER/bs_seeker2-align.py -1 batch_read1/$i.fastq -2 batch_read2/$i.fastq --aligner=bowtie2 -o $i.bam -f bam -m 0.1 -g GENOME-REF-SEQ.fa --bt2-p 10 --bt2--end-to-end; done

# then merge bam files
samtools merge WGBS.bam *.bam

# or single end alignment
python $BSSEEKER/bs_seeker2-align.py -i batch_read1/$i.fastq --aligner=bowtie2 -o $i.bam -f bam -m 0.1 -g GENOME-REF-SEQ.fa --bt2-p 10 --bt2--end-to-end

# beware, if you align the second read as single end read, you have to reverse complement the data, because of directionality of BS-seq
$TOOLBOX/Parser/FASTQ/revseq_fastq.pl
(does not work with GZIP files yet)


#### step 3 ##### remove duplicates from alignment file
# first sort bam file, if not sorted
samtools sort WGBS.bam WGBS.sorted

# call script to remove duplicates, takes bam, outputs sam
$TOOLBOX/Parser/BAM/removeDuplicatesPairs.pl WGBS.sorted.bam > WGBS.rmdup.sam

# convert back to bam
samtools view -bS -T A_alpina_V3.fa WGBS.rmdup.sam > WGBS.rmdup.bam


#### step 4 ##### call methylated sites
python $BSSEEKER/bs_seeker2-call_methylation.py -i WGBS.rmdup.bam -o WGBS.rmdup_methylCalls --db GENOME-REF-SEQ.fa_bowtie2




