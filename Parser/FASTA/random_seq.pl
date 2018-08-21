#! /usr/bin/perl
use strict;
use warnings;


my $length = shift;

my @nuc = ('A', 'C', 'G', 'T');

print ">1 randomseq\n";
for (my $i = 0; $i < $length; $i++) {
	print $nuc[int(rand(4))];
}
print "\n";

