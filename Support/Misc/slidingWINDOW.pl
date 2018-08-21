#! /usr/bin/perl
use strict;
use warnings;

# written by korbinian schneeberger

# Calculates a sliding window. 
# Input format: line break separated file, featuring all positions

use Getopt::Long;

my %CMD;
my $deldup;
my $ss_count;
my $ws;
my $na;
my $column;
my $outputfile;


GetCom();

open FILE, $CMD{file} or die "Cannot open file:", $CMD{file},"\n";
open OUTPUT, ">".$outputfile or die "Cannot open file:",$outputfile,"\n";

my @window = ();

my $win_sum;
my $win_num;

# init array
my $c_init = 0;
INIT: while (<FILE>) {
	chomp;
	my @a = split " ";
	$window[$c_init] = $a[$column];
	if ($_ ne $na) {
		$win_sum += $a[$column];
		$win_num++;
	}
	$c_init++;
	last INIT if $c_init >= $ws;
}
if ($c_init < $ws) {
	exit  "Too little data for given window size\n";
}

# calc sliding window
my $pos = int($ws / 2) + 1; # 1 initialized
my $c_run = 0;
my $last;
my $print_flag = 1;
my $count = 0;
RUN: while (<FILE>) {
	chomp;

	print_entry();

	# count regulates printing of only the i.th value
	$count++;
	$count = $count % $ss_count;

	# remove value sliding out of the window;
	if ($window[$c_run] ne $na) {
		$win_sum -= $window[$c_run];
		$win_num--;
	}

	#set new
	$pos++;
	my @a = split " ";
	$window[$c_run] = $a[$column];
	if ($window[$c_run] ne $na) {
		$win_sum += $window[$c_run];
		$win_num++;
	}
	$c_run = ($c_run+1)%$ws;

}
# don't forget last
print_entry();



################
# subroutines

sub print_entry {

        if ($deldup == 0) {
                if ($count == 0) {
                        print OUTPUT $pos, "\t", ($win_sum/$win_num), "\n";
                }
        } elsif($deldup == 1) {
                if (defined($last) and ($win_sum/$win_num) == $last) {
                        $print_flag = 0;
                        $last = ($win_sum/$win_num);
                } else {
                        print OUTPUT $pos-1, "\t", $last, "\n" if $print_flag == 0;
                        print OUTPUT $pos, "\t", ($win_sum/$win_num), "\n";

                        $print_flag = 1;
                        $last = ($win_sum/$win_num);
                }
        }
	return(0);
}



sub debug_print_array {

	foreach my $a (@window) {
		print $a, "\n";
	}

}

sub GetCom{

	my @usage = ("\nUsage: slidingWINDOW.pl --file=file --ws=int --nan=char\nwritten by Korbinian Schneeberger\n
                --file=file\tdefine the input file
		--ws=int\tdefine size of sliding window
		--nan=char\tdefine the character indicating missing data

		optional:
		--ss=int\treduce the number of reported values, only report each ss.th data point (not with -dd)
		--column\t\tColumn of the file to be parsed (starting from 1)
		-dd\t\tPostprocessing: delete duplicated values, only report values before and after changes (not with --ss)
		\n\n");
 
	die(@usage) if (@ARGV == 0);
	GetOptions(\%CMD, "file=s", "ws=s", "nan=s","dd","ss=s", "column=s");

	die("Please specify input file\n") 				if not defined $CMD{file};
	die("Please specify window size\n") 				if not defined $CMD{ws};
	die("Please specify character indicating missng data\n")	if not defined $CMD{nan};

	if (defined($CMD{dd})) {
        	$deldup = 1;
	} else {
		$deldup = 0;
	}

	if (defined($CMD{ss})) {
		$ss_count = $CMD{ss};
		if ($deldup == 1) {
			die ("don't combine -dd and --ss\n");
		}
        } else {
                $ss_count = 1;
        }


	if (int($CMD{ws}/2) == ($CMD{ws}/2)) {
		die("Window size needs to be odd in a sliding window approach.\n");
	}

	if (defined($CMD{column})) {
                $column = $CMD{column} - 1;
		if ($column < 0) {
			$column = 0;
		}
        } else {
                $column = 0;
        }

	$ws = $CMD{ws};
	$na = $CMD{nan};

	$outputfile = $CMD{file}.".ws".$ws.".txt";

}
	      

