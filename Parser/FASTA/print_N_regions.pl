#! /usr/bin/perl
use strict;
use warnings;

my $usage = "$0 file\n";

my $file   = shift or die $usage;

open FILE, $file or die "Cannot open $file\n";

my $id = "";
my $seq = "";

while(my $line = <FILE>) {
	chomp($line);
	my @a = split " ", $line;
	if (substr($a[0], 0, 1) eq ">") {
		
		if ($seq ne "") {
			parse($id, $seq)
		}
		
		$id = get_id($line);
                $seq = "";
	}
	else {
		$seq .= $line;
	}
}
if ($seq ne "") {
	parse($id, $seq);
}

exit(0);



sub parse {
	my ($id, $seq) = @_;
	my $beg = -1;
	my $i = 0;
	for ($i = 0; $i < length($seq); $i++) {
		if (substr($seq, $i, 1) eq "n" or substr($seq, $i, 1) eq "N") {
			if ($beg == -1) {
				$beg = $i;
			}
		}
		else {
			if ($beg != -1) {
				print $id, "\t", $beg+1, "\t", $i-1+1, "\n";
			}
			$beg = -1;
		}
	}
	if ($beg != -1) {
		print $id, "\t", $beg+1, "\t", $i-1+1, "\n";
	}
}

sub get_id {
	my ($s) = @_;
	my @a = split " ", $s;
	return (substr($a[0], 1, length($a[0])-1));
}



