#! /usr/bin/perl
use strict;
use warnings;


use Getopt::Long;

my %CMD;
my $fastq = "";

GetCom();


open FASTQ, $fastq or die "Cannot open fastq file\n";

my $c = 1;

while (my $line = <FASTQ>) {
	if(substr($line, 0, 1) eq "@") {
		my @a = split " ", $line;
		#print ">".$a[0]."\n";
		print ">".$c."\n";
		my $seq = <FASTQ>;
		chomp($seq);
		print "$seq\n";
		$seq = <FASTQ>;
		$seq = <FASTQ>;
		$c++;
	}
	else { print "file format not correct!\n"; exit(0); }
}




exit(0);

sub GetCom{

  my @usage = ("Usage: $0\n

required:
--fastq\tfastq formatted file

Will be converted into a fastq file.
	");

	die @usage if ($ARGV[0] eq "");
	GetOptions(\%CMD, "fastq=s");

	die("Please specify fastq file\n") unless defined($CMD{fastq});
  
	$fastq = $CMD{fastq};


}
	      

