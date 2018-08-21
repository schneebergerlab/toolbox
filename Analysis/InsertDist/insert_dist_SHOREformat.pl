#! /usr/bin/perl
use strict;
use warnings;


use Getopt::Long;
use Cwd;

my $dir = getcwd;
my %CMD;
my $map1;
my $map2;
my $min;
my $max;
my $readlength;

GetCom();

open MAP1, $map1 or die "Cannot open $map1\n";
open MAP2, $map2 or die "Cannot open $map2\n";
open INSERT_DIST, ">insert.dist.txt" or die "Cannot open outputfile";

my $chr1 = 1;
my $pos1 = 0;
my $chr2 = 1;
my $pos2 = 0;

my %READS1 = ();
my %READS2 = ();

my $count = 0;
while (not (eof(MAP1) and eof(MAP2))) {

	$count++;
	print STDERR $chr1, "\t", $pos1, "\n" if $count%100000 == 0;

	##################
	# Read in sequence
	if ((eof(MAP2)) or (not(eof(MAP1)) and ($chr1 < $chr2 or ($chr1 == $chr2 and $pos1 <= $pos2)))) {
		my $line = <MAP1>;
		my @entries = split " ", $line;
		my $read_id = $entries[3];
		my $read_chr = $entries[0];
		my $read_pos = $entries[1];
		my $read_dir = $entries[4];
		my $read_hits = $entries[6];
		if (defined($READS2{$read_id})) {
			if ($read_hits == 1) {
				my @pair_entries = split "#", $READS2{$read_id};
				my $pair_chr = $pair_entries[0];
				my $pair_pos = $pair_entries[1];
				my $pair_dir = $pair_entries[2];

				print_insertsize($read_id, $read_chr, $read_pos, $read_dir, $pair_chr, $pair_pos, $pair_dir);
			}

			### Delete pair from hash
			delete $READS2{$read_id};
			
		}
		else {
			if ($read_hits == 1) {
				$READS1{$read_id} = $read_chr."#".$read_pos."#".$read_dir;
			}
		}

		$chr1 = $read_chr; $pos1 = $read_pos;
	}
	else {
		my $line = <MAP2>;
                my @entries = split " ", $line;
                my $read_id = $entries[3];
                my $read_chr = $entries[0];
                my $read_pos = $entries[1];
                my $read_dir = $entries[4];
                my $read_hits = $entries[6];
                if (defined($READS1{$read_id})) {
			if ($read_hits == 1) { 
	                        my @pair_entries = split "#", $READS1{$read_id};
        	                my $pair_chr = $pair_entries[0];
                	        my $pair_pos = $pair_entries[1];
                        	my $pair_dir = $pair_entries[2];

				print_insertsize($read_id, $read_chr, $read_pos, $read_dir, $pair_chr, $pair_pos, $pair_dir);
			}

			### Delete pair from hash
			delete $READS1{$read_id};

                }
                else {
			if ($read_hits == 1) {
	                        $READS2{$read_id} = $read_chr."#".$read_pos."#".$read_dir;
			}
                }

		$chr2 = $read_chr; $pos2 = $read_pos;
	}

}

close INSERT_DIST;
system("R --slave --vanilla --args '$dir/insert.dist.txt' $min $max < plot_insert_dist.R");

exit(0);

sub print_insertsize {
	my ($read_id, $read_chr, $read_pos, $read_dir, $pair_chr, $pair_pos, $pair_dir) = @_;
	
	if (	$read_chr == $pair_chr and 
		abs($read_pos-$pair_pos) <= $max and abs($read_pos-$pair_pos) >= $min and
		$read_dir ne $pair_dir and 
		(($read_dir eq "D" and $read_pos < $pair_pos) or ($read_dir eq "P" and $read_pos > $pair_pos)))  {
	        	print INSERT_DIST (abs($read_pos-$pair_pos)+$readlength), "\n";
	}
}

sub GetCom {

  my @usage = ("
Usage: 	$0 

--map1\t\tmap.list first run
--map2\t\tmap.list second run
--max\t\tMax insert size 
--min\t\tMin insert size 
--readlength\t\tLength of sequences

\n");

        die(@usage) if (@ARGV == 0);
        GetOptions(\%CMD, 
			"map1=s", "map2=s", "max=s", "min=s", "readlength=s");

	die("Please specify map.list forward\n") unless defined($CMD{map1});
	die("Please specify map.list reverse\n") unless defined($CMD{map2});
	die("Please specify max insert size\n") unless defined($CMD{max});
	die("Please specify minimum insert size\n") unless defined($CMD{min});
	die("Please specify readlength\n") unless defined($CMD{readlength});

	$map1 = $CMD{map1};
        $map2 = $CMD{map2};
        $max = $CMD{max};
	$min = $CMD{min};
	$readlength = $CMD{readlength};

}

