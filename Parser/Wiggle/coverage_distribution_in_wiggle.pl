#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 file\n";
my $file   = shift or die $usage;


### Read coverage idstribution from wiggle file
my %cov_dist = ();
open IN, $file or die "Cannot open input file\n";
while( <IN> ) {
	chomp;

	if( $_ =~ /track/ ) {
		# nothing for now
	}
	elsif( $_ =~ /fixedStep/ ) {
		my @a = split("\t", $_);
		# TODO: read chr, start, step, span
	}
	else {
		$cov_dist{$_}++;
	}
}
close IN;


### Print results
my $covsum = 0;
print "coverage\twindows\tpositions\tCumulative positions >= cov\n";
foreach my $cov (sort {$b<=>$a} keys %cov_dist) {

	my $positions = $cov_dist{$cov} * 20;
	$covsum += $positions;
	print "$cov\t" . $cov_dist{$cov} . "\t$positions\t$covsum\n";
}

exit(0);
