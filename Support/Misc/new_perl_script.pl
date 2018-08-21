#! /usr/bin/perl
use strict;
use warnings;



my $usage = "$0 raw\|fasta\n";
my $type = "";
$type = shift;
if ($type ne "raw" and $type ne "fasta")  { die $usage; }

### print HEADER

if (1) {

print STDOUT 

"my \$usage = \"\$0 file\\n\";

open FILE, shift or die \$usage;
";

}

## print RAW

if ($type eq "raw") {

print STDOUT
"while (<FILE>) {
	my \@a = split \" \";
	
}
";

}

## print FASTA

if ($type eq "fasta") {

print STDOUT

"my \%SEQ = ();
my \$seq = \"\";
my \$id = \"\";

while (<FILE>) {
	if (substr(\$_, 0, 1) eq \">\") {
		my \@a = split \" \", \$_;
		if (\$seq ne \"\") {
			\$SEQ{\$id} = \$seq;
		}
		\$id = substr(\$a[0], 1, length(\$a[0])-1);
		\$seq = \"\";
	}
	else {
		chomp(\$_);
		\$seq .= \$_;
	}
}
if (\$seq ne \"\") {
	\$SEQ{\$id} = \$seq;
}
";

}



