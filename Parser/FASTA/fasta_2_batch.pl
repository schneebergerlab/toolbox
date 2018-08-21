#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 file batchnumber\n";
my $file = shift or die $usage;
my $batch = shift or die $usage;
if ($batch < 1) {
	die ("batchnumber must be larger than 1\n");
}

my $num = `grep -c '^>' $file`;

my $size = ($num / $batch) + 1;

open FILE, $file or die "Cannot open $file\n";

my $count = 0;
my $filenum = 1;
open OUT, ">".$file.".".$filenum or die "Cannot open out file\n";
while (<FILE>) {
	if (substr($_, 0, 1)  eq ">") {
		$count++;
		if ($count >= $size) {
			$filenum++;
			close OUT or die "Cannot close out file\n";
			open OUT, ">".$file.".".$filenum or die "Cannot open out file\n";
			$count = 1;
		}
	}
	print OUT $_;
}



exit(0);
