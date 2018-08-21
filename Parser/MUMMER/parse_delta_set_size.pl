#! /usr/bin/perl
use strict;

my $usage = "$0 minsize idfile deltafile\n";
my $MINSIZE = shift or die $usage;
my $idfile = shift or die $usage;
my $deltafile = shift or die $usage;

my %ID = ();

open FILE, $idfile or die "cannot open file $idfile\n";
while (<FILE>) {
	chomp();
	$ID{$_} = 1;
}
close FILE;

open FILE, $deltafile or die "cannot open file $deltafile\n";
my $flag = -1;
my $flag2 = 0;
while (my $l = <FILE>) {
        my @a = split " ", $l;
	if (substr($l, 0, 1) eq ">") { 
		my $id1 = substr($a[0], 1, length($a[0])-1);
		my $id2 = $a[1];
		if (defined($ID{$id1}) and defined($ID{$id2})) { 
			$flag = 1;
			print $l;
		}
		else {
			$flag = 0;
		}	
	}
	elsif ($flag == 1) {
		if ((@a+0) > 1) {
			my $dist1 = 0;
			if ($a[1] > $a[0]) {
				$dist1 = $a[1] - $a[0] + 1;
			}
			else {
				$dist1 = $a[0] - $a[1] + 1;
			}
			my $dist2 = 0;
			if ($a[3] > $a[2]) {
				$dist2 = $a[3] - $a[2] + 1;
			}
			else {
				$dist2 = $a[2] - $a[3] + 1;
			}

			if ($dist1 >= $MINSIZE and $dist2 >= $MINSIZE) {
				$flag2 = 1;
				print $l;
			}
			else {
				$flag2 = 0;
			}
		}
		else {
			if ($flag2 == 1) {
				print $l;
			}
		}
	}
	elsif ($flag == -1) {
		print $l;
	}
}
close FILE;



