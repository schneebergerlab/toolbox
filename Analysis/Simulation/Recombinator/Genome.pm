#! /usr/bin/perl
use strict;
use warnings;

###### 
# NGSbox - bioinformatics analysis tools for next generation sequencing data
#
# Copyright 2007-2011 Stephan Ossowski, Korbinian Schneeberger
# 
# NGSbox is free software: you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or any later version.
#
# NGSbox is distributed in the hope that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# Please find the GNU General Public License at <http://www.gnu.org/licenses/>.
#
#  -------------------------------------------------------------------------
#
#  Module: Analysis::AssociationMapping::Recombinator::Genome.pm
#  Purpose:
#  In:
#  Out:
#


use FindBin;
use lib $FindBin::Bin;
use Chromosome;
use Mutations;

package Genome;

sub new {
	my ($self, $parent1, $parent2) = @_;
	$self = {
		parent1		=> $parent1,
		parent2		=> $parent2,
		backcross	=> 0,
		chromosomes     => {},
	};
	bless $self;
	return $self;
}

#############################################################################################
sub backcrossed_F2 {
	my ($self) = @_;

	$self->{backcross} = 1;

	my $p = int(rand(2))+1;
	if ($p == 1) { 
		$self->{chromosomes}{"chromosome1_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 1, 30432563);
	}
	else { 
		$self->{chromosomes}{"chromosome1_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 1, 30432563);
	}
	$self->{chromosomes}{"chromosome1_p2"} = new Chromosome($self->{parent2}, $self->{parent2}, 1, 30432563);

	$p = int(rand(2))+1;
	if ($p == 1) { 
		$self->{chromosomes}{"chromosome2_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 2, 19705359);
	}
	else {
		$self->{chromosomes}{"chromosome2_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 2, 19705359);
	}
	$self->{chromosomes}{"chromosome2_p2"} = new Chromosome($self->{parent2}, $self->{parent2}, 2, 19705359);

	$p = int(rand(2))+1;
	if ($p == 1) { 
		$self->{chromosomes}{"chromosome3_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 3, 23470805);
	}
	else { 
		$self->{chromosomes}{"chromosome3_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 3, 23470805);
	}
	$self->{chromosomes}{"chromosome3_p2"} = new Chromosome($self->{parent2}, $self->{parent2}, 3, 23470805);

	$p = int(rand(2))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome4_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 4, 18585042);
	}
	else { # both self->{parent2}
		$self->{chromosomes}{"chromosome4_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 4, 18585042);
	}
	$self->{chromosomes}{"chromosome4_p2"} = new Chromosome($self->{parent2}, $self->{parent2}, 4, 18585042);

	$p = int(rand(2))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome5_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 5, 26992728);
	}
	else { # both self->{parent2}
		$self->{chromosomes}{"chromosome5_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 5, 26992728);
	}
	$self->{chromosomes}{"chromosome5_p2"} = new Chromosome($self->{parent2}, $self->{parent2}, 5, 26992728);
}

sub selfed_F2 {
	my ($self) = @_;

	my $p = int(rand(4))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome1_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 1, 30432563);
		$self->{chromosomes}{"chromosome1_p2"} = new Chromosome($self->{parent1}, $self->{parent2}, 1, 30432563);
	}
	if ($p == 2) { 
		$self->{chromosomes}{"chromosome1_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 1, 30432563);
		$self->{chromosomes}{"chromosome1_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 1, 30432563);
	}
	if ($p >= 3) { # both self->{parent2}
		$self->{chromosomes}{"chromosome1_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 1, 30432563);
		$self->{chromosomes}{"chromosome1_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 1, 30432563);
	}

	$p = int(rand(4))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome2_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 2, 19705359);
		$self->{chromosomes}{"chromosome2_p2"} = new Chromosome($self->{parent1}, $self->{parent2}, 2, 19705359);
	}
	if ($p == 2) { # both self->{parent2}
		$self->{chromosomes}{"chromosome2_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 2, 19705359);
		$self->{chromosomes}{"chromosome2_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 2, 19705359);
	}
	if ($p >= 3) { # both self->{parent2}
		$self->{chromosomes}{"chromosome2_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 2, 19705359);
		$self->{chromosomes}{"chromosome2_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 2, 19705359);
	}
	$p = int(rand(4))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome3_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 3, 23470805);
		$self->{chromosomes}{"chromosome3_p2"} = new Chromosome($self->{parent1}, $self->{parent2}, 3, 23470805);
	}
	if ($p == 2) { # both self->{parent2}
		$self->{chromosomes}{"chromosome3_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 3, 23470805);
		$self->{chromosomes}{"chromosome3_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 3, 23470805);
	}
	if ($p >= 3) { # both self->{parent2}
		$self->{chromosomes}{"chromosome3_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 3, 23470805);
		$self->{chromosomes}{"chromosome3_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 3, 23470805);
	}
	$p = int(rand(4))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome4_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 4, 18585042);
		$self->{chromosomes}{"chromosome4_p2"} = new Chromosome($self->{parent1}, $self->{parent2}, 4, 18585042);
	}
	if ($p == 2) { # both self->{parent2}
		$self->{chromosomes}{"chromosome4_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 4, 18585042);
		$self->{chromosomes}{"chromosome4_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 4, 18585042);
	}
	if ($p >= 3) { # both self->{parent2}
		$self->{chromosomes}{"chromosome4_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 4, 18585042);
		$self->{chromosomes}{"chromosome4_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 4, 18585042);
	}
	$p = int(rand(4))+1;
	if ($p == 1) { # both self->{parent1}
		$self->{chromosomes}{"chromosome5_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 5, 26992728);
		$self->{chromosomes}{"chromosome5_p2"} = new Chromosome($self->{parent1}, $self->{parent2}, 5, 26992728);
	}
	if ($p == 2) { # both self->{parent2}
		$self->{chromosomes}{"chromosome5_p1"} = new Chromosome($self->{parent2}, $self->{parent1}, 5, 26992728);
		$self->{chromosomes}{"chromosome5_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 5, 26992728);
	}
	if ($p >= 3) { # both self->{parent2}
		$self->{chromosomes}{"chromosome5_p1"} = new Chromosome($self->{parent1}, $self->{parent2}, 5, 26992728);
		$self->{chromosomes}{"chromosome5_p2"} = new Chromosome($self->{parent2}, $self->{parent1}, 5, 26992728);
	}

}
sub recombine {
	my ($self) = @_;

	for (my $chr = 1; $chr <= 5; $chr++) {
		my $chr1 = "chromosome".$chr."_p1";
		my $chr2 = "chromosome".$chr."_p2";

		$self->recombine_chromosome($chr, $chr1);
		$self->recombine_chromosome($chr, $chr2); 
	}

}


sub recombine_chromosome {
	my ($self, $chromosome, $ref) = @_;
	

	#######################################################
	my $chr_size = 0;

	$chr_size = 30432563 if ($chromosome == 1);
	$chr_size = 19705359 if ($chromosome == 2);
	$chr_size = 23470805 if ($chromosome == 3);
	$chr_size = 18585042 if ($chromosome == 4);
	$chr_size = 26992728 if ($chromosome == 5);

	#######################################################
	# The number of recombinations
	# Real world measurements performed by Patrice Salmone
	my @prob = (); my $a = 0; my $b = 0; my $c = 0;
	
	if ($chromosome == 1) {
		# 150, 156, 130 (0, 1, 2 Recombinations) = 436
		# 150/436 = a^2 
		$a = 0.6004;
		# 156/436 = (a * b) + (b * a)
		$b = 0.2980;
		$c = 1 - $a - $b;
		@prob = ($a*10000, $b*10000, $c*10000);
	}
	if ($chromosome == 2) {
		# 267, 133, 36 (0, 1, 2 Recombinations) = 436
		# 267/436 = a^2
		$a = 0.7826;
		# 133/436 = (a * b) + (b * a)
		$b = 0.1949;
		$c = 1 - $a - $b;
		@prob = ($a*10000, $b*10000, $c*10000);
	}
	if ($chromosome == 3) {
		# 230, 136, 70 (0, 1, 2 Recombinations) = 436
		# 230/436 = a^2
		$a = 0.7263;
		# 136/436 = (a * b) + (b * a)
		$b = 0.2147;
		$c = 1 - $a - $b;
		@prob = ($a*10000, $b*10000, $c*10000);
	}
	if ($chromosome == 4) {
		# 269, 122, 45 (0, 1, 2 Recombinations) = 436
		# 269/436 = a^2
		$a = 0.7855;
		# 122/436 = (a * b) + (b * a)
		$b = 0.1781;
		$c = 1 - $a - $b;
		@prob = ($a*10000, $b*10000, $c*10000);
	}
	if ($chromosome == 5) {
		# 166, 155, 115 (0, 1, 2 Recombinations) = 436
		# 166/426 = a^2
		$a = 0.6170;
		# 155/436 = (a * b) + (b * a)
		$b = 0.2881;
		$c = 1 - $a - $b;
		@prob = ($a*10000, $b*10000, $c*10000);
	}

	my $recombination_num = $self->get_rand(\@prob);

	#######################################################
	# Determine recombination location(s) 
	

	my @loc = ();
	my @num = ();

	if ($chromosome == 1) {
		@loc = (32807,488426,1149280,1390502,1865285,2192374,2674225,3167371,3779036,4200550,4359800,5506917,5734744,6149751,6884867,6989379,7047756,8439006,8993233,9001217,9205325,10434922,10903254,11838780,12179065,12686038,13038240,13859051,14001934,14158183,14161442,15605577,15630635,15897174,15985718,16913975,17605952,17720368,18028852,18300423,18514173,18800489,19492844,19780232,20686611,21167712,21559246,23381914,23906908,24114746,24810967,25304145,25520382,26099650,26357422,27230162,27634939,28132789,29333952,30269940,30393984);
		@num = (0,14,29,11,10,6,13,9,15,16,14,36,1,4,19,2,2,41,17,0,9,33,16,31,17,25,29,25,1,0,1,3,1,0,0,44,35,1,10,3,6,7,13,10,21,6,5,36,17,6,25,13,8,21,19,28,7,6,39,16,1);		
	}
	if ($chromosome == 2) {
                @loc = (988154,1172482,1788467,1986922,2033717,2324211,4778556,4811650,5469974,6044749,6809099,6809112,7400522,8225326,8561080,9057864,9461465,9792570,9885676,10365194,10811132,11029317,11193105,11537081,12019213,12717797,13156699,13659835,13796827,14053664,15097876,15445245,15980603,16325026,16600230,16858265,17124023,17766645,18324318,19006196,19582242);
		@num = (0,38,29,5,2,16,11,1,4,20,33,0,27,18,7,13,10,17,4,27,13,2,6,13,15,27,12,7,3,7,23,13,14,11,10,12,9,24,20,22,16);
	}
	if ($chromosome == 3) {
                @loc = (290174,400931,1315978,1813427,2069771,2541354,3427299,3610073,4330513,4900563,5334452,5891629,6008178,7123630,7359421,8456601,8633204,9136628,10358588,10847881,11107344,11748521,12276692,12785230,13107123,13495418,14104253,14244642,15712057,15913994,16629399,17211862,17878794,18258898,18532958,18772306,19221428,19458259,19990665,20809850,20997826,21142865,21899579,22221736,22446488,22806789,23088778,23211977);
		@num = (0,3,29,13,8,5,19,4,18,16,13,9,3,28,4,48,5,27,57,31,15,36,6,4,1,3,0,4,17,5,42,12,28,9,6,8,18,6,23,12,3,3,12,10,8,14,10,3);
	}
	if ($chromosome == 4) {
                @loc = (208650,434712,2103325,3002169,4169509,5643991,6293204,7340898,7724867,8034821,8585617,10346818,11017270,11559979,12439446,13467985,13788227,13960078,14736664,15325586,16102064,16437564,16487609,17031668,17538469,18060948,18405517);
		@num = (0,28,57,0,2,53,46,49,24,10,12,60,25,9,36,17,3,4,17,11,11,13,4,23,19,29,7);
	}
	if ($chromosome == 5) {
                @loc = (271377,508090,778236,1166716,1384732,1917139,2229415,2287470,2736279,3162852,3619476,4233682,5010563,5337548,5799941,6519202,6801277,7047330,7340989,8427379,9358168,10782718,13211824,13445912,13848611,14139628,14303285,14894827,15282634,15878281,16583743,16816665,17115580,17591339,17959456,18089003,18638175,18707445,19320777,19697188,19723111,21294493,21757545,21901746,22203115,23272788,23447475,24757037,25612289,26040116);
		@num = (0,23,18,24,1,16,13,4,13,5,19,13,13,8,14,23,4,8,9,37,49,57,6,3,20,19,7,15,14,22,25,11,12,13,14,6,26,4,34,10,0,42,19,6,15,31,4,29,25,17);
	}


	#######################################################
	# Get exact position of the first recombination:

	my $recombination_loc1 = 0;
	my $recombination_loc2 = 0;

	if ($recombination_num >= 1) { 

		my $marker = $self->get_rand(\@num);
	
		my $pos1 = 0; 
		my $pos2 = $loc[$marker];
		if ($marker > 0) {
			$pos1 = $loc[$marker-1];
		}
		
		$recombination_loc1 = int(rand($pos2-$pos1-1)) + $pos1;

	}

	#######################################################
	# Get exact position of the second recombination:

	if ($recombination_num == 2) {
		my $parachute_count = 0;
		while ($recombination_loc2 < 1 or $recombination_loc2 > $chr_size) {
			$parachute_count++;

			my $id = $self->get_inner_distance($chromosome);



			if ($recombination_loc1 < $chr_size / 2) {
				$recombination_loc2 = $recombination_loc1 + $id;
			}
			else {
				$recombination_loc2 = $recombination_loc1 - $id;
				my $tmp = $recombination_loc2;
				$recombination_loc2 = $recombination_loc1;
				$recombination_loc1 = $tmp;
			}

			if ($parachute_count > 100000) {
				print STDERR "Parachute count large\n";
			}
		}

	}

	#######################################################
	# Determine the mosaik of the chromosomes

	$self->{chromosomes}{$ref}->{recombination_num} = $recombination_num;
	$self->{chromosomes}{$ref}->{recombination_loc1} = $recombination_loc1;
	$self->{chromosomes}{$ref}->{recombination_loc2} = $recombination_loc2;

	if ($recombination_num == 0) {
		push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{sample};
	}
	elsif ($recombination_num == 1) {
		if ($recombination_loc1 <= $chr_size/2) {
			push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{recomb};
			push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{sample};
		}	
		else {
			push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{sample};
			push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{recomb};
		}
	}
	elsif ($recombination_num == 2) {
		push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{recomb};
		push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{sample};
		push @{$self->{chromosomes}{$ref}->{mosaik}}, $self->{chromosomes}{$ref}->{recomb};
	}

	#print join(",",@{$self->{mosaik}}), "<<<\n";

	return(1);
}

sub get_inner_distance {
	my ($self, $chromosome) = @_;

	my $inner_distance = 0;

	my $shape = 0;
	my $scale = 0;                
	if ($chromosome == 1) {     
		$shape = 6.400738469;
		$scale = 2302566.375;
	}
	if ($chromosome == 2) {
		$shape = 6.659992829;                        
		$scale = 1551647.086;
	}
	if ($chromosome == 3) {
		$shape = 6.734141406;
		$scale = 1762373.674;                
	}
	if ($chromosome == 4) {
		$shape = 6.806563364;
		$scale = 1484460.003;
	}
	if ($chromosome == 5) {
		$shape = 6.976312529;
		$scale = 1979111.573;
	}
	# Make R print out a random number based on the gamma distribution
	my $cmd = "R --slave --vanilla --args $shape $scale < ".$FindBin::Bin."/gammad.R";
	#print $cmd,"\n";
	system($cmd);
	open FILE, "gammad.txt" or die "Cannot open file\n";
	$inner_distance = <FILE>;
	chomp($inner_distance);
	close FILE;
	system("rm gammad.txt");

	return int($inner_distance);
}



sub get_rand {
	my ($self, $arr_ref) = @_;

	my @arr = @{$arr_ref};
	my $sum = 0;

	for (my $i = 0; $i < @arr; $i++) {
		$sum += $arr[$i];
	}

	my $value = int(rand($sum))+1;

	for (my $i = 0; $i < @arr; $i++) {
		$value -= $arr[$i];
		if ($value <= 0) {
			return $i;
		}
	}

	return -1;

}


sub phenotype {
	my ($self, $sample, $chromosome, $position, $homo, $het)  = @_;

	#print "Sample ", $sample, " ", $chromosome, " ", $position, " ", $dominant, "\n";

	my $chr1_mutated = 0;
        my $chr2_mutated = 0;

	if ($chromosome == 1) {
		$chr1_mutated = $self->{chromosomes}{chromosome1_p1}->genotype($sample, $position);
		$chr2_mutated = $self->{chromosomes}{chromosome1_p2}->genotype($sample, $position);
	}
        if ($chromosome == 2) {
                $chr1_mutated = $self->{chromosomes}{chromosome2_p1}->genotype($sample, $position);
                $chr2_mutated = $self->{chromosomes}{chromosome2_p2}->genotype($sample, $position);
        }
        if ($chromosome == 3) {
                $chr1_mutated = $self->{chromosomes}{chromosome3_p1}->genotype($sample, $position);
                $chr2_mutated = $self->{chromosomes}{chromosome3_p2}->genotype($sample, $position);
        }
        if ($chromosome == 4) {
                $chr1_mutated = $self->{chromosomes}{chromosome4_p1}->genotype($sample, $position);
                $chr2_mutated = $self->{chromosomes}{chromosome4_p2}->genotype($sample, $position);
        }
        if ($chromosome == 5) {
                $chr1_mutated = $self->{chromosomes}{chromosome5_p1}->genotype($sample, $position);
                $chr2_mutated = $self->{chromosomes}{chromosome5_p2}->genotype($sample, $position);
        }


	if (($chr1_mutated + $chr2_mutated == 2 and $homo == 1) or ($chr1_mutated + $chr2_mutated == 1 and $het == 1)) {
		return 1;
	}
	else {
		return 0;
	}

}

sub genotype {
	my ($self, $sample, $chromosome, $position) = @_;
	my $c1 = "chromosome".$chromosome."_p1";
	my $c2 = "chromosome".$chromosome."_p2";
	return $self->{chromosomes}{$c1}->genotype($sample, $position) + $self->{chromosomes}{$c2}->genotype($sample, $position);
}

sub get_rough_genotypes {
	my ($self) = @_;

	my $ret = "";

	$ret .= "Chromosome 1:\n";
	$ret .= $self->{chromosomes}{"chromosome1_p1"}->get_rough_genotype_string()."\n";
	$ret .= $self->{chromosomes}{"chromosome1_p2"}->get_rough_genotype_string()."\n";
	$ret .= "Chromosome 2:\n";
        $ret .= $self->{chromosomes}{"chromosome2_p1"}->get_rough_genotype_string()."\n";
        $ret .= $self->{chromosomes}{"chromosome2_p2"}->get_rough_genotype_string()."\n";
	$ret .= "Chromosome 3:\n";
        $ret .= $self->{chromosomes}{"chromosome3_p1"}->get_rough_genotype_string()."\n";
        $ret .= $self->{chromosomes}{"chromosome3_p2"}->get_rough_genotype_string()."\n";
	$ret .= "Chromosome 4:\n";
        $ret .= $self->{chromosomes}{"chromosome4_p1"}->get_rough_genotype_string()."\n";
        $ret .= $self->{chromosomes}{"chromosome4_p2"}->get_rough_genotype_string()."\n";
	$ret .= "Chromosome 5:\n";
        $ret .= $self->{chromosomes}{"chromosome5_p1"}->get_rough_genotype_string()."\n";
        $ret .= $self->{chromosomes}{"chromosome5_p2"}->get_rough_genotype_string()."\n";

	return $ret;

}


1;
