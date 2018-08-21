#! /usr/bin/perl
use strict;
use warnings;


use Getopt::Long;
use FindBin;
use lib $FindBin::Bin;

use Read;
use needle_controller;

my $blatfile;
my $referencefile;
my $readsfile;
my $weak;
my @READS = ();


## Parse command line
my %CMD;
GetCom();


## Set up needle alignment obj
my $needle = new needle_controller();
$needle->init($referencefile, $readsfile);


## Parse blat output
parse_file($blatfile);
#remove_weak_alignments($weak); # dangerous for break points


## Parse alignments for HDR alignments
parse_deletion_alignments();


## Parse deletions
sub parse_deletion_alignments {
        foreach my $read(@READS) {
		$read->set_deletion_alignment();
        }
}


## Remove unreliable alignments
sub remove_weak_alignments {
	foreach my $read(@READS) {
		$read->remove_repetitive_alignments($weak);
	}
}

## Parse blatoutput to structures

sub parse_file {

	my $readid = "";
	my $read;

	open BLATOUT, $blatfile or die "Cannot open file: ".$blatfile."\n";

	while (my $line = <BLATOUT>) {
		my @e = split " ", $line;
		my $match = $e[0];

		my $c_read_id = $e[9];
		my $c_read_length = $e[10];
		my @c_read_starts = split ",", $e[19];
		my @c_read_block_seq = split ",", $e[21];

		my $c_target_id = $e[13];
		my @c_target_starts = split ",", $e[20];
		my @c_target_block_seq = split ",", $e[22];

		my @c_block_lengths = split ",", $e[18];

		my @c_read_ends = ();
		my @c_target_ends = ();

		for (my $i = 0; $i < @c_read_starts; $i++) {
			$c_read_starts[$i]++;
			$c_target_starts[$i]++;
			$c_read_ends[$i] = $c_read_starts[$i] + $c_block_lengths[$i] - 1;
			$c_target_ends[$i] = $c_read_starts[$i] + $c_block_lengths[$i] - 1;
		}


		if ($readid ne $c_read_id) {
			$read = new Read();
			$read->{id} = $c_read_id;

			push @READS, $read;
			$readid = $c_read_id;
		}

		$read->add_alignment($match, $c_read_length, \@c_read_starts, \@c_read_ends, \@c_read_block_seq, $c_target_id, \@c_target_starts, \@c_target_ends, \@c_target_block_seq);

	}

}


sub GetCom {

        my @usage = ("$0 --blat file --reference file --reads file

default:
--weak  percentage fuzzy similariy btw blat alignments      5

\n");

        die(@usage) if (@ARGV == 0);
        GetOptions(\%CMD, "blat=s", "weak=s", "reference=s", "reads=s");

        die("Please specify blat file\n") unless defined($CMD{blat});
        die("Please specify reference file\n") unless defined($CMD{reference});
        die("Please specify read file\n") unless defined($CMD{reads});

        $blatfile = $CMD{blat};
        $readsfile = $CMD{reads};
        $referencefile = $CMD{reference};

        if (defined($CMD{weak})) {
                $weak = $CMD{weak};
        }
	else  {
		$weak = 5;
	}
}


