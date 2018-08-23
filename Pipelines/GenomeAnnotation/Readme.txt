
## step 0): Prepare working environment
Tools :
  EVM
  AUGUSTUS  
  SNAP
  GlimmerHMM
  exonerate
  hisat2
  stringtie
Data :
  protein fasta files
  RNA-seq reads fastq files

Configure the "annotation.config" file

## step 1):  Run EVM evidence-based protein-coding gene annotation
python ../scripts/evm.pasa.integrate.pipeline.py -f ./annotation.config

## step 2):  Repeat annotation
Tools : RepeatMaske, RepeatModeler, blastp
RepeatMasker -species arabidopsis -gff -dir ./ -pa 20 ../../reference/chr.all.v1.0.fasta
perl ../../../scripts/repeat.classfied.gff3.pl ./chr.all.v2.0.fasta.out.gff ./chr.all.v2.0.fasta.out ./chr.all.v2.0.fasta.repeats.ann.gff3 repeat.ann.stats &
egrep -v 'Low|Simple|RNA|other|Satellite' chr.all.v2.0.fasta.repeats.ann.gff3 |cut -f 1,4,5,9 >chr.all.v2.0.TE.bed


## step 3):   Noncoding gene annotation
 cmscan --cpu 20 --tblout Rfam.scan.out ../../../data/Rfam/Rfam.cm ../chr.all.v1.0.split.fasta > run.log 
 nohup perl  ../../../scripts/noncoding.infernal.output.parser.pl ./Rfam.scan.out ./ >nohup.out &

## step 4):  Find TE related gene and update gene model gff file
  perl ../../../scripts/remove.TErelated.genes.pl ../../EVM_PASA/evm.annotation.protein.fasta ../../EVM_PASA/evm.annotation.gene.fasta ../RepeatMasker/chr.all.v1.0.TE.bed ../../EVM_PASA/evm.all.gff3 ./ > remove.TE.log & 
python ./scripts/gene.id.update.py -i ./ -v 1.0 >log/gene.id.update.log &

## step 5a):  Evaluate (Optional)
nohup python -u ../../../scripts/annotation.evaluate.find-mis.py -g ./groups.txt -o ./run2 -n  Col.prot.besthit.out2 -c query.prot.besthit.out2 -p blastp.result -s Col.prot.gene.bed -q query.prot.gene.bed -x Col.prot.fasta -y query.prot.fasta -a Col.gene.LoF.txt -b query.gene.LoF.txt -r ../../RNAseq/hisat2/rnaseq.4evm.gff >np.run2&

## step 6): Update (Optional)
nohup python -u ../../../scripts/update.misann.genes.py -u genes.to.be.updated.txt -g annotation.genes.gff -o ./run2 -s scipio.gff -x Col.gene.LoF.txt -y query.gene.LoF.txt -c ChrCM.txt -a augustus.ann.gff -n SNAP.4evm.gff -l glimmerhmm.4evm.gff -b ./Col.gene.blastn.besthit.bed  -f ../../reference/chr.all.v2.0.fasta -p Col.prot.fasta -i ./Col.prot.gene.bed >update.run2.log  &
nohup python -u ../../scripts/annotation.gene.ID.update.py -i ../evaluation/update/run2/updated.highConf.gff -n ./tmp/Kyo.genes.annotation.2.0.gff -o ../version2 -v v2.0 -a Kyo -g ../reference/chr.all.v2.0.fasta > updateID.log

