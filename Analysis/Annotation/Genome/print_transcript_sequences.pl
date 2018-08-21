#! /usr/bin/perl
use strict;
use warnings;

my $fasta = shift or die;
my $gff = shift or die;

my %chr = ();
my $current_name = "";


### Read chromosomes/scaffolds from fasta file
open FASTA, $fasta or die "Cannot open fasta file\n";
while (<FASTA>) {
	chomp;
	if( $_ =~ /^>/ ) {
		$current_name = $_;
		$current_name =~ s/>//g;
	}
	else {
		$chr{$current_name} .= $_;
	}
}
close FASTA or die "Cannot close fasta file\n";



### Read genes from gff file
my %gene = ();
my %exons = ();
my %cds = ();
my $last_gene = "NA";
my $last_protein_id = "";
my $last_transcript_id = "";
my $name = "";
my $junk = "";

open GENEUTR, ">$fasta.gene_utr" or die "Cannot open output file $fasta.gene_utr\n";
open GENE,    ">$fasta.gene"     or die "Cannot open output file $fasta.gene\n";
open CDS,     ">$fasta.cds"      or die "Cannot open output file $fasta.cds\n";
open NEWGFF,  ">$gff.new"        or die "Cannot open output file $gff.new\n";
open PSEUDO,  ">$gff.pseudo"     or die "Cannot open output file $gff.pseudo\n";
open ERROR,   ">$gff.error"      or die "Cannot open output file $gff.error\n";
open GFF, $gff or die "Cannot open gff file\n";

while(<GFF>) {
	chomp;
	my @elem = split("\t", $_);
	my @column9 = split(";", $elem[8]);
	($junk, $name) = split(" ", $column9[0]);
	$name =~ s/"//g;

	### Start new gene and print last gene
	if( $last_gene ne $name && $last_gene ne "NA" ) {

		### Get real gene length
		my $min = 99999999999;
		my $max = -1;
		foreach my $start ( sort { $a <=> $b } keys %exons ) {
			if($exons{$start}[3] < $min) { $min = $exons{$start}[3]; }
			if($exons{$start}[4] > $max) { $max = $exons{$start}[4]; }
		}

		### Print gff entry and fasta sequence for coding genes
		if( (exists $gene{start}) && (exists $gene{stop}) ) {

			### Print new gff file
			my $gene_seq = "";
			my $error_flag = 0;

			### Gene on forward strand
			if( ($gene{start}[6] eq "+") && ($gene{start}[3] < $gene{stop}[3]) ) {
				# GFF entry for gene, start and stop codon
				print NEWGFF $gene{start}[0] . "\t" . $gene{start}[1] . "\tprotein_coding_gene\t" . $min . "\t" . $max . "\t.\t" . $gene{start}[6] . "\t.\t" . $gene{start}[8] . "\n";
				print NEWGFF $gene{start}[0] . "\t" . $gene{start}[1] . "\t" . $gene{start}[2] . "\t" . $gene{start}[3] . "\t" . $gene{start}[4] . "\t" . $gene{start}[5] . "\t" . $gene{start}[6] . "\t" . $gene{start}[7] . "\t" . $gene{start}[8] . "\n";
				print NEWGFF $gene{stop}[0] . "\t" . $gene{stop}[1] . "\t" . $gene{stop}[2] . "\t" . $gene{stop}[3] . "\t" . $gene{stop}[4] . "\t" . $gene{stop}[5] . "\t" . $gene{stop}[6] . "\t" . $gene{stop}[7] . "\t" . $gene{stop}[8] . "\n";

				# gene excluding UTR
				$gene_seq = substr( $chr{ $gene{start}[0] }, $gene{start}[3] - 1, $gene{stop}[4] - $gene{start}[3] + 1 );
				print GENE ">$last_protein_id | $last_gene | $last_transcript_id\n$gene_seq\n";

				# gene excluding UTR
				$gene_seq = substr( $chr{ $gene{start}[0] }, $min - 1, $max - $min + 1 );
				print GENEUTR ">$last_protein_id | $last_gene | $last_transcript_id\n$gene_seq\n";
			}

			# Gene on reverse strand
			elsif( ($gene{start}[6] eq "-") && ($gene{stop}[3] < $gene{start}[3]) ) {
				# GFF entry for gene, start and stop codon
				print NEWGFF $gene{start}[0] . "\t" . $gene{start}[1] . "\tprotein_coding_gene\t" . $min . "\t" . $max . "\t.\t" . $gene{start}[6] . "\t.\t" . $gene{start}[8] . "\n";
				print NEWGFF $gene{start}[0] . "\t" . $gene{start}[1] . "\t" . $gene{start}[2] . "\t" . $gene{start}[3] . "\t" . $gene{start}[4] . "\t" . $gene{start}[5] . "\t" . $gene{start}[6] . "\t" . $gene{start}[7] . "\t" . $gene{start}[8] . "\n";
				print NEWGFF $gene{stop}[0] . "\t" . $gene{stop}[1] . "\t" . $gene{stop}[2] . "\t" . $gene{stop}[3] . "\t" . $gene{stop}[4] . "\t" . $gene{stop}[5] . "\t" . $gene{stop}[6] . "\t" . $gene{stop}[7] . "\t" . $gene{stop}[8] . "\n";

				# gene excluding UTR
				$gene_seq = substr( $chr{ $gene{start}[0] }, $gene{stop}[3] - 1, $gene{start}[4] - $gene{stop}[3] + 1);
				$gene_seq = reverse($gene_seq);
				$gene_seq =~ tr/ACGTacgt/TGCATGCA/;
				print GENE ">$last_protein_id | $last_gene | $last_transcript_id\n$gene_seq\n";

				# gene including UTR
				$gene_seq = substr( $chr{ $gene{start}[0] }, $min - 1, $max - $min + 1);
				$gene_seq = reverse($gene_seq);
				$gene_seq =~ tr/ACGTacgt/TGCATGCA/;
				print GENEUTR ">$last_protein_id | $last_gene | $last_transcript_id\n$gene_seq\n";

			}

			# Wrong annotation detected
			else { 
				print ERROR "$last_protein_id | $last_gene | $last_transcript_id\n";
				$error_flag = 1;
			}

			### Exons
			if( $error_flag == 0 ) {
				### Print RNA exons including UTR, excluding introns
				foreach my $start ( sort { $a <=> $b } keys %exons ) {
					print NEWGFF $exons{$start}[0] . "\t" . $exons{$start}[1] . "\t" . $exons{$start}[2] . "\t" . $exons{$start}[3] . "\t" . $exons{$start}[4] . "\t.\t" . $exons{$start}[6] . "\t.\t" . $exons{$start}[8] . "\n";
				}


				### Print coding exons (CDS) excluding UTR and intron
				my $cds_seq = "";
				my $ori = "+";
				foreach my $start ( sort { $a <=> $b } keys %cds ) {
					print NEWGFF $cds{$start}[0] ."\t". $cds{$start}[1] ."\t". $cds{$start}[2] ."\t". $cds{$start}[3] ."\t". $cds{$start}[4] ."\t". $cds{$start}[5] ."\t". $cds{$start}[6] ."\t". $cds{$start}[7] ."\t". $cds{$start}[8] ."\n";

					$cds_seq .= substr( $chr{ $cds{$start}[0] }, $cds{$start}[3] - 1, $cds{$start}[4] - $cds{$start}[3] + 1);
		
					if($cds{$start}[6] eq "-") { $ori = "-"; }
				}

				if( $ori eq "-" ) {
					$cds_seq = reverse($cds_seq);
					$cds_seq =~ tr/ACGTacgt/TGCATGCA/;
				}
				print CDS ">$last_protein_id | $last_gene | $last_transcript_id\n$cds_seq\n";
			}
		}

		### Print Pseudogene
		else {
			print NEWGFF $gene{general}[0] . "\t" . $gene{general}[1] . "\tpseudogene\t" . $min . "\t" . $max . "\t.\t" . $gene{general}[6] . "\t.\t" . $gene{general}[8] . "\n";

			foreach my $start ( sort { $a <=> $b } keys %exons ) {
				print NEWGFF $exons{$start}[0] . "\t" . $exons{$start}[1] . "\t" . $exons{$start}[2] . "\t" . $exons{$start}[3] . "\t" . $exons{$start}[4] . "\t.\t" . $exons{$start}[6] . "\t.\t" . $exons{$start}[8] . "\n";
			}

			print PSEUDO "$last_protein_id | $last_gene | $last_transcript_id\n";
		}

		### Reset container
		%gene = ();
		%exons = ();
		%cds = ();
		$last_gene = "";
		$last_transcript_id = "";
		$last_protein_id = "";
	}


	### Store segment specific data
	if   ( $elem[2] eq "start_codon" )   { $gene{start}  = \@elem; }
	elsif( $elem[2] eq "stop_codon" )    { $gene{stop} = \@elem; }

	elsif( $elem[2] eq "exon" ) {
		$exons{$elem[3]} = \@elem;
		$gene{general} = \@elem;
		my ( $gene_id, $transcript_id) = split(";", $elem[8]);
		($junk, $last_transcript_id) = split(" ", $transcript_id);
	}       
	elsif( $elem[2] eq "CDS" ) {           
		$cds{$elem[3]} = \@elem; 
		my ( $gene_id, $protein_id, $exon_nr) = split(";", $elem[8]);
		($junk, $last_protein_id) = split(" ", $protein_id);
	}       

	$last_gene = $name;

}

exit(0);
