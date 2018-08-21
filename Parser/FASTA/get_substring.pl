#! /usr/bin/perl
use strict;
use warnings;


my $LINE_LENGTH = 80;

my $usage = "$0 file newFastaID id begin end\nIf begin is larger than end, sequence will be reported rev comp from end to begin\n";

my $file   = shift or die $usage;
my $new_id = shift or die $usage;
my $id     = shift or die $usage;
my $begin  = shift or die $usage;
my $end    = shift or die $usage;

open FILE, $file or die "Cannot open $file\n";

my $seq = "";
my $flag = 0;

while(my $line = <FILE>) {
	chomp($line);
	my @a = split " ", $line;
	if (substr($a[0], 0, 1) eq ">") {
		if ($flag == 1) {
			if ($begin <= $end) {
				print ">".$new_id." ".$id."_".$begin."_".$end."\n";
				print_l(substr($seq, $begin-1, $end-$begin+1));
			}
			else {
				print ">".$new_id." ".$id."_".$begin."_".$end."_revcomp\n";
				my $seq = substr($seq, $end-1, $begin-$end+1);
				$seq = revcomp($seq);
				print_l($seq);
			}
			exit(0);
		}

		if ($id eq substr($a[0], 1, length($a[0])-1)) {
			$flag = 1;
		}
		else {
			$flag = 0;
		}

                $seq = "";
	}
	else {
		$seq .= $line;
	}
}

if ($flag == 1) {
	if ($begin <= $end) {
 	       print ">".$new_id." ".$id."_".$begin."_".$end."\n";
        	print substr($seq, $begin-1, $end-$begin+1), "\n";
         }
                        else {
                                print ">".$new_id." ".$id."_".$begin."_".$end."_revcomp\n";
                                my $seq = substr($seq, $begin-1, $end-$begin+1);
                                $seq = revcomp($seq);
                                print_l($seq);
                        }
}

exit(0);


sub revcomp {
        my ($seq) = @_;

        my $newseq = reverse $seq;
        $newseq =~ tr/ACTGactgMRVHmrvhKYBDkybd/TGACtgacKYBDkybdMRVHmrvh/;

        return $newseq;
}

sub print_l {
	my ($seq) = @_;

	my $bseq = "";

	for (my $i = 0; $i < length($seq); $i++) {
		if ($i % $LINE_LENGTH == 0 && $i != 0) {
			$bseq .= "\n";
		}
		$bseq .= substr($seq, $i, 1);
	}
	$bseq .= "\n";

	print $bseq;
}



