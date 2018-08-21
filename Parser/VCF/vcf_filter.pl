#! /usr/bin/perl
use strict;
use warnings;


my $usage = "\n$0 vcf_file max_depth\n\n";

my $vcf       = shift or die $usage;
my $max_depth = shift or die $usage;

open VCF, $vcf or die "Cannot open input file\n";

while( my $line = <VCF> ) {
	chomp($line);

	if($line =~ /^#/) {
		print "$line\n";
	}
	else {
		my @a = split("\t", $line);
		my @b = split(";", $a[7]);	# Annotations
		my @c = split(":", $a[8]);	# Genotypes order
		my @d = split(":", $a[9]);	# Genotypes values

		# Get annotation
		my %anno = ();
		foreach my $anno_string (@b) {
			my($type, $value) = split("=", $anno_string);
			$anno{$type} = $value;
		}

		### Get genotype
		my %geno = ();
		for(my $i = 0; $i < $#c; $i++) {
			$geno{$c[$i]} = $d[$i];
		}

		my ($ref_support, $snp_support) = split(",", $geno{AD});

		### Default: $snp_support >= 3 && $anno{DP} >=5 && $anno{DP} <= 250 && $anno{AF} >= 0.3 && $anno{RE} <= 1.3 && $a[5] >= 20
		if( $snp_support >= 3 && $anno{DP} >=5 && $anno{DP} <= $max_depth && $anno{AF} >= 0.3 && $anno{RE} <= 1.3 && $a[5] >= 20 ) { 
			print "$line\n";
		}
	}
}

close VCF;

exit(0);
