#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fasta [targetSize(=105236502)]\n";
my $file = shift or die $usage;
my $size = shift;

###########################################################
# Read in file
open FILE, $file or die $usage;

my %CTG_LTH = ();
my $seq = "";
my $cum_lth = 0;
my $num_n = 0;
my $count = 0;

while (my $line = <FILE>) {
	chomp($line);
	if (substr($line, 0, 1) eq ">") {
		if ($seq ne "") {
			$CTG_LTH{length($seq)}++;
			$cum_lth += length($seq);
			for (my $i=0; $i<length($seq); $i++) { $num_n++ if (uc(substr($seq, $i, 1)) eq "N"); }
		}
		$seq = "";
		$count++;
	}
	else {
		$seq .= $line;
	}
}
if ($seq ne "") {
	$CTG_LTH{length($seq)}++;
	$cum_lth += length($seq);
	for (my $i=0; $i<length($seq); $i++) { $num_n++ if (uc(substr($seq, $i, 1)) eq "N"); }
}


###########################################################
# Analyze lengths and number
my $L50 = -1;
my $N50 = -1;
my $L50_target = -1;
my $N50_target = -1;
my $max = 0;
my $min = -1;

my $add = 0;
my $counter = 0;

foreach my $length (sort {$b <=> $a} keys %CTG_LTH) {
	$counter+=$CTG_LTH{$length};
	
	# set max length
	if ($max < $length) {
		$max = $length;
	}
	if ($min == -1 || $min > $length) {
		$min = $length;
	}
	# set N50
	$add += ($length*$CTG_LTH{$length});
	if  ($N50 == -1 and $add >= $cum_lth/2) {
		$L50 = $length;
		$N50 = $counter;
	}
	if  (defined($size) and $N50_target == -1 and $add >= $size/2) {
                $L50_target = $length;
                $N50_target = $counter;
        }
}

print "################\n";
print "Total scaffold count:\t\t$count\n";
print "Total scaffold length:\t\t$cum_lth\n";
print "Longest scaffold:\t\t$max\n";
print "Shortest scaffold:\t\t$min\n";
print "################\n";
print "Sequence information:\t\t"; printf("%.3f", 100*(1-$num_n/$cum_lth)); print "%\n";
print "Total number ambiguous bases:\t$num_n\n";
print "################\n";
print "# Intrinsic:\n";
print "N50/L50:\t\t\t", $N50, " / ", $L50, "\n";
if (defined($size)) {
print "################\n";
print "# Target genome:\n";
print "Genome coverage:\t\t"; printf("%.3f", 100*$cum_lth/$size); print "% (",$cum_lth,"bp of ",$size,"bp)\n";
print "N50/L50:\t\t\t", $N50_target," / ", $L50_target, "\n";
}


