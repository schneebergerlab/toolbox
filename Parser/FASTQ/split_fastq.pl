#! /usr/bin/perl
use strict;
use warnings;



my $split = shift;
my $file  = shift;

my $count = 0;
my $file_count = 1;

open IN, $file or die "Cannot open input file\n";
open OUT, ">$file.$file_count" or die "Cannot open output file\n";


my $line = "";
while( $line = <IN> ) {
	# Print 4 lines of fastq entry
	print OUT $line;
	$line = <IN>;
	print OUT $line;
	$line = <IN>;
	print OUT $line;
	$line = <IN>;
	print OUT $line;

	$count++;

	if($count >= $split) {
		if($file_count > 2) { exit; }

		$count = 0;
		$file_count++;
		close OUT;
		open OUT, ">$file.$file_count" or die "Cannot open output file\n";
	}
}
close IN; close OUT;

exit(0);
