#! /usr/bin/perl
use strict;
use POSIX qw(ceil floor);

my %MATCH = ();
my %CHRSIZE = ();
my %CENT = ();

my $usage="$0 alignmentFile chrSizesFile centFile winSize\n";
my $file = shift or die $usage;
my $csfile = shift or die $usage;
my $centfile = shift or die $usage;
my $WINDOW_SIZE = shift or die $usage;

open FILE, $file or die $usage;

while (my $line = <FILE>) {
	if (substr($line, 0, 1) eq "s") {
		my $spe1 = $line;
		my $spe2 = <FILE>;
		chomp($spe1); 
		chomp($spe2);
		parse_alignment($spe1, $spe2);
	}
}

get_chr_sizes($csfile);
get_centromeres($centfile);

if (defined($CENT{1}{93})) {
	print STDERR "YES\n";
}

print_windows();

exit(0);


sub print_windows {

	open OUT, ">$file.MATCH.WS$WINDOW_SIZE.txt" or die "cannot open output file\n";
	open OUTC, ">$file.MATCH.woCent.WS$WINDOW_SIZE.txt" or die "cannot open output file\n";

	foreach my $chr (sort {$a <=> $b} keys %MATCH) {
		for (my $i = 1; $i <= $CHRSIZE{$chr}; $i++) {
			if (defined($MATCH{$chr}{$i})) {
				print OUT "$chr\t$i\t", $MATCH{$chr}{$i}, "\n";
				if (not defined ($CENT{$chr}{$i})) {
					print OUTC "$chr\t$i\t", $MATCH{$chr}{$i}, "\n";
				}
			}
			else { 
				print OUT "$chr\t$i\tNA\tNA\tNA\n";
				if (not defined ($CENT{$chr}{$i})) {
					print OUTC "$chr\t$i\tNA\tNA\tNA\n";
                                }
			}
		}
	}

}



sub parse_alignment {
	my ($spe1, $spe2) = @_;

	my @algn1 = split " ", $spe1;
	my @algn2 = split " ", $spe2;

	#Example line (before alignment sequence)
	#s Chr1    433426 50836 + 30427671 
	my $chr1 = $algn1[1];
	$chr1 =~ s/Chr//g;
	my $start1 = $algn1[2];
	my $end1 = $start1 + $algn1[3] - 1;

	my $seq1 = $algn1[6];
	my $seq2 = $algn2[6];

	my $match = 0;
	my $mismatch = 0;
	if (length($seq1) >= $WINDOW_SIZE) {
		for (my $i = 1; $i < length($seq1); $i++) {
			my $n1 = substr($seq1, $i-1, 1);
			my $n2 = substr($seq2, $i-1, 1);
			## Is it a match?
			if ($n1 eq $n2 and $n1 ne "N" and $n1 ne "-") {
				$match++;
			}
			if ($i > $WINDOW_SIZE) {
				my $r1 = substr($seq1, $i-1-$WINDOW_SIZE, 1);
                        	my $r2 = substr($seq2, $i-1-$WINDOW_SIZE, 1);
				if ($r1 eq $r2 and $r1 ne "N" and $r1 ne "-") {
					$match--;
				}
			}
			## Is it real mismatch?
			if ($n1 ne $n2 and $n1 ne "N" and $n2 ne "N") {
                                $mismatch++;
                        }
                        if ($i > $WINDOW_SIZE) {
                                my $r1 = substr($seq1, $i-1-$WINDOW_SIZE, 1);
                                my $r2 = substr($seq2, $i-1-$WINDOW_SIZE, 1);
                                if ($r1 ne $r2 and $r1 ne "N" and $r2 ne "N") {
                                        $mismatch--;
                                }
                        }

			if ($i >= $WINDOW_SIZE) {
				my $pos = $start1+$i-floor($WINDOW_SIZE/2);
				if ($mismatch+$match >= $WINDOW_SIZE/2) {
					$MATCH{$chr1}{$pos} = sprintf("%.2f", $match/($match+$mismatch));
				}
				else {
					$MATCH{$chr1}{$pos} = "SM";
				}
				$MATCH{$chr1}{$pos} .= "\t$match\t$mismatch";
			}
		}	
	}


}


sub get_chr_sizes {
	my ($file) = @_;
	open FILE, $file or die "cannot open file\n";
	while (<FILE>) {
		my @a = split " ";
		$CHRSIZE{$a[0]} = $a[1];		
	}
}


sub get_centromeres {
        my ($file) = @_;
        open FILE, $file or die "cannot open file\n";
        while (<FILE>) {
                my @a = split " ";
#print STDERR $a[0]," ",$a[1]," ",$a[2],"\n";
		for (my $i = $a[1]; $i <= $a[2]; $i++) {	
                	$CENT{$a[0]}{$i} = 1;
		}
        }
}





