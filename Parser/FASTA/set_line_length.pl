#! /usr/bin/perl
use strict;
use warnings;



my $usage = "$0 fasta linelength\n";
my $file = shift or die $usage;
my $ll = shift or die $usage;
open FILE, $file or die $usage;

my $seq = "";

while (my $line = <FILE>) {
        chomp($line);
        if (substr($line, 0, 1) eq ">") {
                if ($seq ne "") {
			print_seq();
                }
		print $line, "\n";
		$seq = "";
        }
        else {
                $seq .= $line;
        }
}
print_seq();


sub print_seq {
	my $count = 0;
	for (my $i = 0; $i < length($seq); $i++) {
		$count++;
		print substr($seq, $i, 1);
		print "\n" if $count%$ll == 0;
	}
	print "\n" if $count%$ll != 0;

}


