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
#  Module: Analysis::AssociationMapping::Recombinator::Mutations.pm
#  Purpose:
#  In:
#  Out:
#



package Mutations;

sub new {
	my ($self) = @_;
	$self = {
		chromosome	=> (),
		position	=> (),
		sample	    	=> (),
		fraction     	=> (),
	};
	bless $self;
	return $self;
}

#############################################################################################
sub set {
	my ($self) = @_;	

	$self->{chromosome}[0] = 4;
	$self->{position}[0] = 16702262;
	$self->{sample}[0] = "Col-0";
	$self->{fraction}[0] = 1;

	return(1);
}


1;
