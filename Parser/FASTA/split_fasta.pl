#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: split.fasta.pl
#
#        USAGE: ./split.fasta.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Wen-Biao Jiao (), 
# ORGANIZATION: Department of Plant Developmental Biology, Max Planck Institute for Plant Breeding Research
#      VERSION: 1.0
#      CREATED: 08/27/2018 09:57:14 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use File::Basename;
use Bio::Seq;
use Bio::SeqIO;
use Getopt::Long;

my $usage = "$0 -- split a fasta file in smaller multiple fasta files.\n\n";
$usage .= "Usage: $0 -f input.fa [ -s n or -n n ]-o outdir \n\n";
$usage .= "parameters:\n";
$usage .= "-f|-fa=s          input fasta file\n";	
$usage .= "-s|--size=n       number of bases in each split fasta file \n";
$usage .= "-o|--outdir=s     output directory\n";
$usage .= "                  s/input.split.1.fa\n";
$usage .= "                  s/input.split.2.fa\n";
$usage .= "                  s/input.split.3.fa\n";
$usage .= "                  ... \n";
$usage .= "-n|--num=n        number of sequences in each split fasta file" ;
$usage .= "\n";



if (@ARGV < 1) {
    print $usage;
    exit;
}

my ($faFile, $size, $num, $outdir);
$size = 0;
$outdir = "";
$num = 0 ;

GetOptions('s|size:i'=>\$size,
           'n|num:i' =>\$num,
           'f|fa:s' =>\$faFile,
           'o|outdir:s'=>\$outdir);

if (! -e $faFile) {
	print "cannot find the file $faFile \n" ;
	exit;
}  

if (! -d $outdir) {
	system("mkdir -p $outdir");
}

my $basename = basename($faFile);
$basename =~ s/(\.fa|\.fna|\.fasta)$//;
my $outp = "$outdir/$basename.split";

if ($size > 0 and $num > 0) {
	print "either size or num is set, cannot be set together\n";
	exit;
}

if ($size > 0 ) {
	print "split the fasta file by base\n";
	splitBase($faFile, $outp, $size);
} 

if ($num > 0 ) {
	print "split the fasta file by number\n";
	splitNum($faFile, $outp, $num);
}
 

sub splitNum {
	my ($fastaFile, $outp, $num) =@_ ;
	my $seqin = new Bio::SeqIO(-file=>$fastaFile, -format=>"fasta");
	my $n = 1;
	my $k = 0;
	my $outFile = $outp . ".$n.fa" ;
	my $seqout = new Bio::SeqIO(-file=>">$outFile", -format=>"fasta");

	while (my $seqobj=$seqin->next_seq()) {
		if ($k <= $num) {
			$seqout->write_seq($seqobj);
			$k += 1 ;
		}else {
			$n += 1 ;
			$k = 0;
			$outFile = $outp . ".$n.fa" ;
			#print $outFile, "\n" ;
			$seqout = new Bio::SeqIO(-file=>">$outFile", -format=>"fasta");
			$seqout->write_seq($seqobj);
			$k += 1 ;			
		}
	}
}

sub splitBase {
	my ($fastaFile, $outp, $size) =@_ ;
	my $seqin = new Bio::SeqIO(-file=>$fastaFile, -format=>"fasta");
	my $n = 1;
	my $k = 0;
	my $outFile = $outp . ".$n.fa" ;
	my $seqout = new Bio::SeqIO(-file=>">$outFile", -format=>"fasta");

	while (my $seqobj=$seqin->next_seq()) {
		my $leng = $seqobj->length();		
		if ($k <= $size) {
			$seqout->write_seq($seqobj);
			$k += 1 ;
			$k += $leng;
		}else {
			$n += 1 ;
			$k = 0;
			$outFile = $outp . ".$n.fa" ;
			$seqout = new Bio::SeqIO(-file=>">$outFile", -format=>"fasta");
			$seqout->write_seq($seqobj);
			$k += $leng ;			
		}
	}
}

