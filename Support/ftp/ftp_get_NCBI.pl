#! /usr/bin/perl
use strict;
use warnings;

use Net::FTP;

local $| = 1;

### Directory structure of refseq/release on ftp.ncbi.nih.gov:
my $host = "ftp.ncbi.nih.gov";
my $dir = "/refseq/release";
my $suffix = ".genomic.fna.gz";
my $tmp_dir = "/srv/netscratch/dep_coupland/grp_schneeberger/tmp";


### Connect and go to dir
my $ftp = Net::FTP->new($host, Debug => 0) or die "Cannot connect to %host: $@";
$ftp->login("anonymous",'-anonymous@') or die "Cannot login as anonymous", $ftp->message;
$ftp->binary();
$ftp->cwd($dir) or die " ERROR: Cannot change working directory: ", $ftp->message;


### Parse Folders
my @species = $ftp->ls();

foreach my $s (@species) {

	next if($s eq "complete" or $s eq "README");

	### Parse files in folder
	my $subdir = "$dir/$s";
	print "SUBDIR: $subdir\n";
	
	$ftp->cwd($subdir) or die " ERROR: Cannot change working directory: ", $ftp->message;
	my @files = $ftp->ls("*$suffix");

	foreach my $f (@files) {
	
		my $remote_file = "$subdir/$f";
		print "REMOTEFILE: $remote_file\n";
		my $local_file = "$tmp_dir/$subdir/$f";
		print "LOCALFILE: $local_file\n";

		if(stat $local_file) {
			print "  $local_file already exist. Skipping.\n\n";
			next;
		}

		system("mkdir -p $tmp_dir/$subdir");


		### Get file
		if($ftp->get($remote_file, $local_file)) {
			print "$remote_file [OK]\n";
		}
		else {
			print STDERR "[ERROR] Can not stat file: $remote_file\n";
			next;
		}
	}
}

### Finish
$ftp->quit;
exit 0;

