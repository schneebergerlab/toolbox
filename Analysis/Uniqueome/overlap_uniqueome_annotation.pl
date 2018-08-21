#! /usr/bin/perl

my $usage = "$0 uniqueome annotation\n";
my $ufile = shift or die $usage;
my $afile = shift or die $usage;


## read in uniqueome

my %U = ();
open OUT, ">$ufile.genomewide" or die "cannot open out file\n";
print OUT "#c_unique\tc_mildly_rep\tc_rep\n";
my $gc_u = 0;
my $gc_m = 0;
my $gc_r = 0;
open FILE, $ufile or die $usage;
while (<FILE>) {
	my @a = split " ";
	$U{$a[0]}{$a[1]} = $a[3];
	if ($a[3] eq "u") {
		$gc_u++;
	}
	elsif ($a[3] eq "m") {
		$gc_m++;
	}
	elsif ($a[3] eq "r") {
		$gc_r++;
	}
}
print OUT "$gc_u\t$gc_m\t$gc_r\n";
close OUT;
close FILE;



## parse genes

my %CDS_CHR = ();
my %CDS_START = ();
my %CDS_END = ();

open FILE, $afile or die "cannot open file\n";
while (<FILE>) {
        my @a = split " ";
	if ($a[0] ne "UNKNOWN" and $a[0] ne "chloroplast" and $a[0] ne "mitochondrion" and $a[1] eq "protein_coding" and $a[2] eq "CDS") {
		my $gene = substr($a[9], 1, length($a[9])-3);
		push @{$CDS_CHR{$gene}}, $a[0];
		my $s = $a[3];
		my $e = $a[4];
		if ($s > $e) {
			my $t = $s;
			$s = $e;
			$e = $t;
		}
		push @{$CDS_START{$gene}}, $s;
		push @{$CDS_END{$gene}}, $e;
	}
}

close FILE;


# overlaps uniqueome?

open OUT, ">$ufile.gene_overlap" or die "cannot open out file\n";
print OUT "#geneID\tc_unique\tc_mildly_rep\tc_rep\n";
foreach my $gene (keys %CDS_CHR) {
	my $c_u = 0;
        my $c_m = 0;
        my $c_r = 0;
	my %P = ();
	for (my $i = 0; $i < @{$CDS_CHR{$gene}}; $i++) {
		for (my $p = ${$CDS_START{$gene}}[$i]; $p <= ${$CDS_END{$gene}}[$i]; $p++) {
			if (not defined($P{$p})) {
				my $chr = ${$CDS_CHR{$gene}}[$i];
				if (defined($U{$chr}{$p})) {
					my $state = $U{$chr}{$p};
					$c_u++ if $state eq "u";
					$c_m++ if $state eq "m";
					$c_r++ if $state eq "r";
				}
				$P{$p} = 1;
			}
		} 
	}

	print OUT "$gene\t$c_u\t$c_m\t$c_r\n";

}

	









