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
#  Module: Analysis::AssociationMapping::Recombinator::Chromosome.pm
#  Purpose:
#  In:
#  Out:
#


use FindBin;
use lib $FindBin::Bin;


package Chromosome;

sub new {
	my ($self, $sample, $recomb, $chromosome, $size) = @_;
	$self = {
		sample		=> $sample,
		recomb		=> $recomb,
		chromosome	=> $chromosome,
		size		=> $size,
		recombination_num	=> 0,
		recombination_loc1	=> 0,
		recombination_loc2	=> 0,
		mosaik		=> [],
	};
	bless $self;
	return $self;
}


sub genotype {
	my ($self, $sample, $position) = @_;
	
	my $genotype = "";

	if ($self->{recombination_num} == 0) {
		$genotype = ${$self->{mosaik}}[0];
	}

	if ($self->{recombination_num} == 1) {
		if ($self->{recombination_loc1} > $position) { 
			$genotype = $self->{mosaik}[0];
		}	
		else {
			$genotype = $self->{mosaik}[1];
		}
	}

	if ($self->{recombination_num} == 2) {
		if ($position < $self->{recombination_loc1}) {
                	$genotype = $self->{mosaik}[0];
		}
		elsif ($position >= $self->{recombination_loc1} and $position <= $self->{recombination_loc2}) {
			$genotype = $self->{mosaik}[1];
		}
		else {
			$genotype = $self->{mosaik}[2];
		}
        }

	if ($sample eq $genotype) {
		return 1;
	}
	else {
		return 0;
	}

}

sub get_rough_genotype_string {
	my ($self) = @_;
	my $str = "";

	for (my $i = 0; $i < $self->{size}; $i+=1000000) {
		if ($self->genotype($self->{sample}, $i) == 1) {
			$str .= substr($self->{sample}, 0, 1);
		}
		else {
			$str .= substr($self->{recomb}, 0, 1);
		}
	} 
	return $str;
}

1;
