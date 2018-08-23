# Here is a quick example with simulated data.
# for real data practice, please refer to http://bioinfo.mpipz.mpg.de/shoremap/SHOREmap_v3.0.html

# tools
#    shore: read alignment and variant calling (alternative: bowtie2/samtools/bcftools)
#    SHOREmap (compatible with dell or hpc)
#
export /srv/netscratch/dep_coupland/grp_schneeberger/bin/shore/
export /biodata/dep_coupland/grp_schneeberger/projects/methods/src_shq/srcSHOREmap/

# open a new terminal, get into the folder examples

###################################################################################################
# step 1: read alignment

## create a new folder named withSHORE to collect the corresponding results

cd examples
mkdir withSHORE

## index the reference sequence ./data/S.imulated.ref.fa to ../withSHORE/index

cd data
shore preprocess -f S.imulated.ref.fa -i ../withSHORE/index

## change into the folder genome_center

cd ../genome_center/

## shore requires a special format on short reads, which can be prepared with the command (if paired end, provide -y as well)

shore import -v fastq -e Shore -a genomic -x read_data.fq -o ../withSHORE/flowcell

## align formatted reads to the indexed reference sequence (Option '-n' tells the program that the maximum number of edit distances is L*10%; '-g' tells the program that the maximum number of mismatches is L*7%, where L is the length of reads)

shore mapflowcell -f ../withSHORE/flowcell -i ../withSHORE/index/S.imulated.ref.fa.shore -n 10% -g 7%

## run the consensus-calling program to predict the mutations (SNPs, indels, and SV)

shore consensus -n example1 -f ../withSHORE/index/S.imulated.ref.fa.shore -o ../withSHORE/consensus_het -i ../withSHORE/flowcell/1/single/map.list.gz -g 5 -a /srv/netscratch/dep_coupland/grp_schneeberger/bin/shore/scoring_matrix_het.txt -v

###################################################################################################
# step 2: mapping-by-sequencing 

## SHOREmap accepts files resulted from SHORE wihtout any further modification. In practice, 
## files like consensus_summary.txt.gz can be as large as tens to hundreds of gygabytes, 
## which might be repeatedly parsed during SHOREmap analysis. 
## To save file parsing time in analysis, 
## extract the consensus information only related to the candidate SNP markers. 

## change to folder withSHORE

cd ../withSHORE

## unzip consensus_summary.txt.gz

gunzip consensus_het/ConsensusAnalysis/supplementary_data/consensus_summary.txt.gz

## extract the necessary consensus information according to consensus_het/ConsensusAnalysis/quality_variant.txt
## result is consensus_het/ConsensusAnalysis/extracted_consensus_0.txt

SHOREmap extract --chrsizes ../data/chrsizes.txt --marker consensus_het/ConsensusAnalysis/quality_variant.txt --consen consensus_het/ConsensusAnalysis/supplementary_data/consensus_summary.txt --folder consensus_het/ConsensusAnalysis

## use SHOREmap backcross to do background correction according to AF and base call quality

SHOREmap backcross --chrsizes ../data/chrsizes.txt --marker consensus_het/ConsensusAnalysis/quality_variant.txt --consen consensus_het/ConsensusAnalysis/extracted_consensus\_0.txt --folder MBS --marker-score 2 --marker-freq 0.2 --cluster 1 -plot-bc

## check visualization of AFs is in BC_AF_visualization_1_boost.pdf

xpdf MBS/BC_AF_visualization_1_.pdf

## Now we can see that there is bell-shaped AF pattern on chr 1, 
## around the peak we can define the mapping interval, which can contain the causal mutation of the phenotype. 
## annotate the mutations in the mapping interval to check their effects on genes. 
## To avoid missing any SNPs, we annotate the initially converted marker file quality_variant.txt. 
## Annotation can be done like this:

SHOREmap annotate --chrsizes ../data/chrsizes.txt --snp consensus_het/ConsensusAnalysis/quality_variant.txt --chrom 1 --start 2500 --end 6500 --folder MBS_annotation --genome ../data/S.imulated.ref.fa --gff ../data/S.imulated.gff -verbose

## Result is in folder MBS_annotation. Check the file,
## which describes mutations and their effect on gene integrity. 
## For example, non-synonymous changes: 1   4137    G   A is more likely to be responsbile for the phenotype. 
## Meanwhile, there is an additional file ref_and_eco_coding_seq.txt, which collects gene and protein sequences.
