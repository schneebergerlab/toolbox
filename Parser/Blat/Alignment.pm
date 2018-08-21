#! /usr/bin/perl
use strict;
use warnings;



package Alignment;


### Constructor
sub new {
	my $self = {
		match  => 0,
		blocks  => 0,
		read_length  => 0,
		read_starts => [],
		read_ends => [],
		read_seqs => [],
		target_id => "",
		target_starts => [],
                target_ends => [],
                target_seqs => [],
	};
	bless $self;
	return $self;
}


sub get_maplist_format {
	my ($self, $hits) = @_;

	return $self->{target_id}."\t";
}


sub init {

	my ($self, $match, $read_length, $read_starts_ref, $read_ends_ref, $read_block_seq_ref, $target_id, $target_starts_ref, $target_ends_ref, $target_block_seq_ref) = @_;
	
	$self->{match} = $match;
	$self->{read_length} = $read_length;
	$self->{read_starts} = @{$read_starts_ref};
	$self->{read_end} = @{$read_ends_ref};
	$self->{read_block_seq} = @{$read_block_seq_ref};
	$self->{target_id} = @{$target_id};
	$self->{target_starts} = @{$target_starts_ref};
        $self->{target_end} = @{$target_ends_ref};
        $self->{target_block_seq} = @{$target_block_seq_ref};	

}


1;
