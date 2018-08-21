#! /usr/bin/perl
use strict;
use warnings;




my $usage = "$0 file chr start end\n";

my $file = shift or die $usage;
my $chr = shift or die $usage;
my $pos = shift or die $usage;
my $end = shift or die $usage;

open FILE, $file or die $usage;

my $flag = 0;
my $id = "";
my $seq = "";
while (my $line = <FILE>) {
	chomp($line);
	if (substr($line, 0, 1) eq ">") {
		print_mask($seq, $id, $chr, $pos, $end);
		my @a = split " ", $line;
		$id = substr($a[0], 1, length($a[0])-1);
		$seq = "";
	}
	else {
		$seq .= $line;
	}	
}
print_mask($seq, $id, $chr, $pos, $end);


sub print_mask {
	my ($seq, $id, $chr, $pos, $end) = @_;


	if ($id ne "") {
		print ">", $id, "\n";
		my $line_break = 0;
	        if ($chr == $id) {
			my $lb = 0;
			for (my $i = 0; $i<$pos-1; $i++) {
	        		print substr($seq, $i, 1);
				$lb++;
				if ($lb%79 == 0) {
					print "\n";
				}
			}
                	for (my $i = 0; $i < $end-$pos+1; $i++) {
                		print "N";
				$lb++;
				if ($lb%79 == 0) {
                                        print "\n";
                                }
	                }
			for (my $i = $end; $i<length($seq); $i++) {
	        	      	print substr($seq, $i, 1);
				$lb++;
				if ($lb%79 == 0) {
                                        print "\n";
                                }
                        }
			if ($lb%79 != 0) {
                        	print "\n";
                        }
	        }
        	else {
			my $i;
			for ($i = 0; $i<length($seq); $i++) {
        			print substr($seq, $i, 1); 
				if (($i+1)%79 == 0) {
					print "\n";
				}
			}
			if ($i+1%79 != 0) {
                                print "\n";
                        }
	        }
	}
}




