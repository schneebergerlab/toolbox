#! /usr/bin/perl
use strict;
use warnings;



my $usage = "\n$0 sample vcf_file\n\n";

my $sample = shift or die $usage;
my $vcf    = shift or die $usage;

open VCF, $vcf or die "Cannot open input file\n";

while( my $line = <VCF> ) {
	chomp($line);

	if($line =~ /^#/) {
		# ignore for now
	}
	else {
		my @a        = split("\t", $line);
		my @info     = split(";", $a[7]);	# Generic info about call
		my @gt_order = split(":", $a[8]);	# Genotypes order
		my @gt_value = split(":", $a[9]);	# Genotypes values

		# Get infotation
		my %info = ();
		foreach my $info_string (@info) {
			my($type, $value) = split("=", $info_string);
			$info{$type} = $value;
		}


		### Get genotype
		my %geno = ();
		for(my $i = 0; $i <= $#gt_order; $i++) {
			$geno{$gt_order[$i]} = $gt_value[$i];
		}


		### Allele support
		my $quality_cov = "\\N";
		my $ref_support = "\\N";
		my $snp_support = "\\N";
		if(exists $geno{DP}) {
			$quality_cov = $geno{DP}
		}
		if(exists $geno{AD}) {
			($ref_support, $snp_support) = split(",", $geno{AD});
		}


		### Enriched regions
		my $enriched = 1;
		if($a[6] =~ /NOTENRICHED/) {
			$enriched = 0;
		}


		### Filter
		my $passed_filter = 0;
		if($a[6] =~ /PASS/) {
			$passed_filter = 1;
		}


		### Hom/Het
		my $homhet = "het";
		if($geno{GT} eq "1/1") {
			$homhet = "hom";
		}


		print 	$sample ."\t". $a[0] ."\t". $a[1] ."\t". $a[3] ."\t". $a[4] ."\t". $a[5] ."\t". 
			$homhet ."\t". 
			$quality_cov ."\t".
			$ref_support ."\t". 
			$snp_support ."\t".
			$passed_filter ."\t".
			$enriched ."\t".
			$info{set} ."\n";
			
	}
}

close VCF;

exit(0);
