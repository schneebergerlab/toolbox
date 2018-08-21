#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fastafile\n";
my $file = shift or die $usage;
open FILE, $file or die $usage;

my %entries = ();
my $id = "";

while (my $line = <FILE>) {

	if (substr($line, 0, 1) eq ">") {
		chomp($line);
		$id = $line;
		$entries{$id} = "";
	}
	else {
		$entries{$id} .= $line;
	}
}

foreach my $header ( sort keys %entries ) {
	print "$header\n" . $entries{$header};
}
	

