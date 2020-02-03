#! /usr/bin/perl
use strict;
use warnings;


my $usage = "\n$0 vcf_file [marker_file-to-restrict-sites]\n\n";

my $vcf        = shift or die $usage;
my $markerfile = shift;

print STDERR "Assumes ref allele equals one of the parental alleles\n";


my %P1 = ();
my %P2 = ();
if (defined ($markerfile )) { 
	open MARKER, $markerfile or die "cannot open marker file\n";
	while (<MARKER>) {
		my @a = split " ";
		my $chr = $a[1];
		if (substr($a[1], 0, 3) ne "Chr") {
			$chr = "Chr".$a[1];
		}
		$P1{$chr}{$a[2]} = $a[3];
		$P2{$chr}{$a[2]} = $a[4];
	}
	close MARKER;
}


open VCF, $vcf or die "Cannot open input file\n";

while( my $line = <VCF> ) {
	chomp($line);

	if($line !~ /^#/) {
		my @a = split("\t", $line);

		if (not defined ($markerfile) or defined($P1{$a[0]}{$a[1]})) {

			my $chr = $a[0]; 
			my $pos = $a[1]; 
			my $ref = $a[3]; 
			my $alt = substr($a[4], 0, 1); # assuming SNP marker only 

			my @b = split(";", $a[7]);

			# Get annotation: Number of high-quality ref-forward, ref-reverse, alt-forward and alt-reverse bases
			my %anno = ();
			foreach my $anno_string (@b) {
				my ($type, $value) = split("=", $anno_string);
				$anno{$type} = $value;
			}
	
			### Get allele counts
			my $ref_c = 0;
			my $alt_c = 0;
			if (defined($anno{"DP4"})) {
				my @c = split ",", $anno{"DP4"};
				$ref_c = $c[0] + $c[1];
				$alt_c = $c[2] + $c[3];
			}

			### PRINT:
			if (defined($markerfile )) {
				if ($ref eq $P1{$chr}{$pos} and ($alt eq $P2{$chr}{$pos} or $alt eq "\.")) {
					print "$chr\t$pos\t$ref\t$ref_c\t$P2{$chr}{$pos}\t$alt_c\n";
				}
			}
			else {
				if (length($ref) == 1 and length($alt) == 1 and $alt ne "-") {
					print "$chr\t$pos\t$ref\t$ref_c\t$alt\t$alt_c\n";
				}
			}
		}
	}
}

close VCF;

exit(0);
