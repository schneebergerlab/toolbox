#! /usr/bin/perl
use strict;
use warnings;



package needle_alignment;


use File::Temp qw/ tempfile tempdir /;

# Example usage:

#my $seq1 = "GGGTTTTAAGATCGCAGGAGTTTCCTAAGAAAAAGGAAGAGAAAAACCTTAAGTTTACTAAAAAAAGGCAAAAGAGAAATATCAAGCTAAAAATAGATAAATACTATGGGAAAAATTATGATTTGTAAGCGTATGTCCTTCTCCAAAATCTCGCTTTCGAGGGTGGGGAGAGAGTAGAAGAGAAATATCAAATTTCCCTTCAAAAGCCTCTCCTCTCTTTGTTCAAGTTTTTTTCCTTGGATGTGCATGTTTCTTGTGGAACAAGGCAGTTCTGTTTTTAAGTAAAATTCATGGCGACGGATTCGTTCATCAAGTTAAATCCAATTTCCTTTAACCGTGCCCGCTTCGACCTCCGAGATTTTGCTGGCATAAGTCCTAAAAGCATCTCTTCTCTGTGTTGCATTAGCCCAAGATTGATATCTTGCAACCATTTCAGCCCGAGAACATTGATATCCGGCGAGAATGGTAACATATTGTTTTCCAAGAAAAAGATCCCCGCGTTTGTCCGATGTCAGGTTAGTTCAAAATCATTAGAAAATTTAATCTTTTTTATCGAACATAGTTAATTTTCTTGAATTGTTTAATCCAGACAAGTCTTGGGATCGGAAGGAACCAAAAATGGTGGGAGAAGGAATTGAAACCGAACATGAAGTCGGTTACATCACCGCAAGATCTTGTCGTCTCTTTACGTAACGCTGGAGATAAACTTGTCGTTGTTGATTTCTTCTCGCCTAGTTGTGGTGGCTGCAAAGCTCTTCATCCCAAGGTAAGCCGGTCTTAATCATCTGAAAAAAATAAACCGGGGACAGCTTTTTACACGAAAGATCTTAAGAATAACTATTTACCAAATTAAGCAAAAACTATTTATAGGATTTAATCAAAATTAACTCAAGTTATGTTGACATTGTGAGTTACTTTAGGTACAGTATCTTGGATTTTATATTTTTATCGTAAATGTGACTTAGATATATATATATTTTCAGATATGTAAAATTGCAGAGA";

#my $seq2 = "GGGTCTTTAAGATCGCAGGAGTTTCCTAAGAAAAAGGAAGAGAAAAACCTTAAGTTTACTAACAAAAGGCAAAAGAGAAATATCAAGCTAAAAATAGATAAATACTATGGGAAAAATTATGATTTGTAAGCGTATGTCCTTCTCCAAAATCTCGCTTTCGAGGGTGGGGAGAGAGTAGAAGAGAAATATCAAATTTCCCTTCAAAAGCCTCTCCTCTCTTCGTTCAAGTTTTTTTCCTTGGATGTGCATGTTTCTTGTGGAACAAGGCAGTTCTGTTTTTAAGTAAAATTCATGGCGACGGATTCGTTCATCAAGTTAAATCCAATTTCCTTTAACCGTGCCCGCTTCGACCTCCGAGATTTTGCTGGCATAAGTCCTAAAAGCATCTCTTCTCTGTGTTGCATTAGCCCAAGATTGATATCTTGCAACCATTTCAGCCCGAGAACATTGATATCCGGCGAGAATGGTAACATATTGTTTTCCAAGAAAAAGATCCCCGCGTTTGTCCGATGTCAGGTTAGTTCAAAATCATTAGAAAATTTAATCTTTTTTATCGAACATAGTTAATTTTCTTGAATTGTTTAATCCAGACAAGTCTTGGGATCGGAAGGAACCAAAAATGGTGGGAGAAGGAATTGAAACCGAACATGAAGTCTGTTACATCACCGCAAGATCTTGTCGTCTCTTTACGTAACGCTGGAGATAAACTTGTCGTTGTTGATTTCTTCTCGCCTAGTTGTGGTGGCTGCATAGCTCTTCATCCCAAGGTAAGCCGGTCTTAATCATCTGAAAAAAATAAACCGGGGACAGCTTTTTACACGAAAGATCTTAAGAATAACTATTTACCAAATTAAGCAAAAACTATTTATAGGATTTAATCAAAATTAACTCAAGTTATGTTGACATTGTGAGTTACTTTAGGTACAGTATCTTGGATTTTATATTTTTATCGTAAATGTGACTTAGATATATATATATTTTCAGATATGTAAAATTGCAGAG";

#my $align = needleman_wunsch($seq1, $seq2);
#my ($snp_ref, $del_ref, $ins_ref) = parse_alignment($align, 0);

#my %snps = %$snp_ref;
#my %dels = %$del_ref;
#my %ins = %$ins_ref;

#print $seq1, "\n";
#print $seq2, "\n";
#print "++++++++++++++++++++++++\n";
#print @$align[0], "\n";
#print "\n";
#print @$align[1], "\n";
#print "++++++++++++++++++++++++\n";
#print "SNPs:\n";
#foreach my $pos (sort {$a <=> $b} keys %snps) {
#	print $pos, "\t", $snps{$pos}, "\n";
#}
#print "++++++++++++++++++++++++\n";
#print "DELETIONS:\n";
#foreach my $pos (sort {$a <=> $b} keys %dels) {
#	print $pos, "\t", $dels{$pos}, "\n";
#}
#print "++++++++++++++++++++++++\n";
#print "INSERTIONS:\n";
#foreach my $pos (sort {$a <=> $b} keys %ins) {
#	print $pos, "\t", $ins{$pos}, "\n";
#}


sub new {
	my ($self) = @_;
	$self = {
		similarity	=> '',
		align_seq1	=> "",
		align_seq2	=> "",
		start		=> 0, # start of the real alignment within the alignment
		end		=> 0, # end of the real alignment within the alignment
		subs		=> {},
		del		=> {},
		ins		=> {},
	 	num_ins         => 0,
		num_subs	=> 0,
		num_del		=> 0,
		#left_overhang	=> 0,
		#right_overhang	=> 0
	};
	bless $self;
	return $self;
}


sub needleman_wunsch {
	my ($self, $seq1, $seq2, $dir) = @_;

	## write tmp files

	my ($fh1, $filename1) = tempfile();
	my ($fh2, $filename2) = tempfile();
	my (undef, $filename3) = tempfile(OPEN => 0);

	print $fh1 $seq1;
	print $fh2 $seq2;

	close $fh1;
        close $fh2;

	## alignment

	my $revflag = "";
	if ($dir ne "+") {
		$revflag = "-sreverse2";
	}

	system('needle '.$filename1.' '.$filename2.' '.$revflag.' -auto -aformat3 fasta -out '.$filename3);

	open FASTA, $filename3 or die "Cannot open file $filename3";
	
	my $seq = -1;
	while (my $line = <FASTA>) {
		chomp($line);
		if (substr($line, 0, 1) eq ">") {
			$seq++;
		} else {
			if ($seq == 0) {
				$self->{align_seq1} .= $line;		
			}
			elsif($seq == 1) {
				$self->{align_seq2} .= $line;
			}
		}
	}

	return (0);
}

sub reverse_comp {
        my ($seq) = @_;
        $seq = reverse($seq);
        $seq =~ tr/ACGTacgt/TGCAtgca/;
        return ($seq);
}



sub parse_fasta_alignment {
	my ($self) = @_;

	#my @a = @$alignment_ref;

	my $del_flag = 0;
	my $del_seq = "";
	my $ins_flag = 0;
	my $ins_seq = "";

	###detect start of alignment
	my $flag_start_seq1 = 0;
        my $flag_start_seq2 = 0;
	for (my $i = 0; $i<length($self->{align_seq1})-1; $i++) {
		my $base1 = substr($self->{align_seq1}, $i, 1);
                my $base2 = substr($self->{align_seq2}, $i, 1);
		if ($base1 ne "N" and $base1 ne "-") {
                        $flag_start_seq1 = 1;
                }
                if ($base2 ne "N" and $base2 ne "-") {
                        $flag_start_seq2 = 1;
                }
		if ($flag_start_seq1 == 1 and $flag_start_seq2 == 1) {
			$self->{start} = $i;
			$i = length($self->{align_seq1})-1;
		}
	}
	##detect end of alignment
	my $flag_end_seq1 = 0;
        my $flag_end_seq2 = 0;
	for (my $i = length($self->{align_seq1})-1; $i >= 0; $i--) {
		my $base1 = substr($self->{align_seq1}, $i, 1);
                my $base2 = substr($self->{align_seq2}, $i, 1);
		if ($base1 ne "N" and $base1 ne "-") {
                        $flag_end_seq1 = 1;
                }
                if ($base2 ne "N" and $base2 ne "-") {
                        $flag_end_seq2 = 1;
                }
		if ($flag_end_seq1 == 1 and $flag_end_seq2 == 1) {
                        $self->{end} = $i;
                        $i = -1;
                }
	}


	for (my $pos = $self->{start}; $pos <= $self->{end}; $pos++) {
		my $base1 = substr($self->{align_seq1}, $pos, 1);
		my $base2 = substr($self->{align_seq2}, $pos, 1);

		# SNPS
		if (uc($base1) ne uc($base2) and $base1 ne "-" and $base2 ne "-" and uc($base1) ne "N" and uc($base2) ne "N") {
			$self->{subs}{$pos} = $base1.$base2;
			$self->{num_subs}++;
		} 

		# DELETIONS
		if ($base2 ne "-") {
			if ($del_flag != 0) {
				$self->{del}{$del_flag} = $del_seq; 
				$self->{num_del}++;
			}
			$del_flag = 0;
			$del_seq = "";
		} else {
			if ($del_flag == 0) {
				$del_flag = $pos;
			}
			$del_seq .= $base1;
		}

		# INSERTIONS
		if ($base1 ne "-") {
			if ($ins_flag != 0) {
				$self->{ins}{$ins_flag} = $ins_seq;
				$self->{num_ins}++;
			}
			$ins_seq = "";
			$ins_flag = 0;
		} else {
			if ($ins_flag == 0) {
				$ins_flag = $pos;
			}
			$ins_seq .= $base2;
		}

	}

	# handle deletions and insertion at the end of the alignment
	if ($del_flag != 0) {
		$self->{del}{$del_flag} = $del_seq;
	}
	if ($ins_flag != 0) {
		$self->{ins}{$ins_flag} = $ins_seq;
	}

	return (0);

}


1;
