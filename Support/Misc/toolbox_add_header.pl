#! /usr/bin/perl
use strict;
use warnings;



my $usage = "\n$0 toolbox_folder\n\n";
my $infolder  = shift or die $usage;



### Dir Level 1
my @l1_folders = glob($infolder . "/*");

foreach my $l1_folder (@l1_folders) {


	### Dir Level 2
	my @l1_path = split("/", $l1_folder);
	my $l1_leaf = $l1_path[$#l1_path];
	my @l2_folders = glob($l1_folder . "/*");

	foreach my $l2_folder (@l2_folders) {
		

		### Dir Level 3
		my @l2_path = split("/", $l2_folder);
		my $l2_leaf = $l2_path[$#l2_path];
		my @l3_folders = glob($l2_folder . "/*");

		foreach my $l3_folder (@l3_folders) {

			### Dir Level 4
			my @l3_path = split("/", $l3_folder);
			my $l3_leaf = $l3_path[$#l3_path];
	
			### Only modify text files
			if( (-T $l3_folder) && ($l3_leaf =~ /\.pl/ || $l3_leaf =~ /\.pm/) ) {
				&modify_script($l3_folder, $l1_leaf."::".$l2_leaf."::".$l3_leaf);
			}

			### Iterate for folders
			elsif( -d $l3_folder ) {
				
				my @l4_folders = glob($l3_folder . "/*");
				
				foreach my $l4_folder (@l4_folders) {
				
					### Dir Level 5
					my @l4_path = split("/", $l4_folder);
					my $l4_leaf = $l4_path[$#l4_path];

					### Only modify text files
					if( (-T $l4_folder) && ($l4_leaf =~ /\.pl/ || $l4_leaf =~ /\.pm/) ) {
						&modify_script($l4_folder, $l1_leaf."::".$l2_leaf."::".$l3_leaf."::".$l4_leaf);
					}

					### Iterate for folders
					elsif( -d $l4_folder ) {

						my @l5_folders = glob($l4_folder . "/*");
						
						foreach my $l5_folder (@l5_folders) {

							### Dir Level 5
							my @l5_path = split("/", $l5_folder);
							my $l5_leaf = $l5_path[$#l5_path];

							### Only modify text files
							if( (-T $l5_folder) && ($l5_leaf =~ /\.pl/ || $l5_leaf =~ /\.pm/) ) {
								&modify_script($l5_folder, $l1_leaf."::".$l2_leaf."::".$l3_leaf."::".$l4_leaf."::".$l5_leaf);
							}

							# -> no deeper folder at the moment
						}
					}
				}
			}
		}
	}
}

sub modify_script {

	my ($file, $module) = @_;

my $header = "
###### 
# Toolbox - bioinformatics analysis tools 
#
# Copyright 2018 Schneeberger lab
# 
# Toolbox is free software: you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or any later version.
#
# Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# Please find the GNU General Public License at <http://www.gnu.org/licenses/>.
#
#  -------------------------------------------------------------------------
#
#  Module: $module
#  Purpose:
#  In:
#  Out:
#
\n");


#
	open IN, $file or die "\nError: Cannot open original perl script\n\n";
	while( <IN> ) {
			push(@mod_file, $_);
		}
	}
	close IN or die;

	open OUT, ">$file" or die "\nError: Cannot open modified perl script\n\n";

	print OUT @mod_file;
}


