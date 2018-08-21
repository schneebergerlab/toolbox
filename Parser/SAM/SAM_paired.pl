#! /usr/bin/perl
use strict;
use warnings;

my $file = shift or die "\n\nUsage: $0 SAMfile\n\n";
open FILE, $file;

while(<FILE>) {
	my @a = split("\t", $_);

	my $is_paired = 1;

	if ( $a[1] & hex(0x0004) ) {
		$is_paired = 0;
	}
	if ( $a[1] & hex(0x0008) ) {
		$is_paired = 0;
	}
	if( $a[8] == 0 ) {
		$is_paired = 0;
	}

	if($is_paired == 1) {
		print $_;
	}
}

close FILE;

exit(0);
