
my $usage = "$0  <genome file>  <variation file> [optional: <chr> <startpos> <endpos>]\n\n";

my $genomefile = shift or die $usage;
my $varfile = shift or die $usage;
my $chrom = shift;
my $start = shift;
my $end   = shift;


if ( ($chrom ne "" || $start ne "" || $end ne "") && ($chrom eq "" || $start eq "" || $end eq "") ) {
	print STDERR "Please specify all: chromosome, start and end position!\n";
	exit(1);
}

open ATH,"<$genomefile" or die "Cannot open file $genomefile\n";
open VAR,"<$varfile" or die "Cannot open file $varfile\n";

my @a, @ath, @chr, @seq;
my $chr;
print STDERR "read in genome\n";
while (<ATH>) {
	chomp;
	if (substr($_, 0, 1) eq ">") {
		$chr = substr($_,1);
		if ($chrom eq "" || $chrom eq $chr) {
			push(@chr, $chr);
		}
	}
	else {
		if ($chrom eq "" || $chrom eq $chr) {
			$ath{$chr} .= $_;
		}
	}
}
print STDERR "done\n";
close ATH;

if ($chrom ne "") {
	my $tmp = substr( $ath{$chrom}, $start-1, $end-$start+1 );
	$ath{$chrom} = $tmp;
#print $ath{$chrom}."\n";
}


my $lastpos = 0;
$chr = 0;
while (<VAR>) {

	chomp;
	@a = split/\t/;

	next if ($chrom ne "" && ($a[1] ne $chrom || $a[2] < $start));
	last if ($chrom ne "" && $a[1] eq $chrom && $a[2] > $end);

#	$a[2] = $a[2] - $start + 1 if ($chrom ne "");
	$a[2] = $a[2] - $start + 1 if ($a[1] eq $chrom);

	if ($a[1] > $chr) {
		print STDERR "$chr -> $a[1]\n";
		if ($chrom eq "" && $chr != 0) {
			$seq{$chr} .= substr($ath{$chr}, $lastpos, length($ath{$chr})-$lastpos);
		}
		$chr = $a[1];
		$lastpos = 0;
	}

	if ($lastpos > $a[2]) {
		print STDERR "error! chr $a[1]: variation within another variation (position $a[2] versus position $lastpos) please check input\n";
		exit;
	}
	elsif ($lastpos != $a[2]) {
		$seq{$chr} .= substr($ath{$chr}, $lastpos, $a[2]-1-$lastpos);
	}

	if ($a[4] =~ m/\d/) {
		# insertion
		$seq{$chr} .= substr($ath{$chr}, $a[2]-1, 1);
		$seq{$chr} .= $a[5];
		$lastpos = $a[2];
	}
	elsif ($a[4] ne "-") {
		# SNP
		$seq{$chr} .= $a[4];
		$lastpos = $a[2];
	}
	elsif ($a[4] eq "-") {
		# deletion
		$lastpos = $a[2];
	}

}
$seq{$chr} .= substr($ath{$chr}, $lastpos, length($ath{$chr})-$lastpos);
close VAR;
close POS;

foreach (@chr) {
	if ($seq{$_} ne "") {
		print ">$_\n".$seq{$_}."\n";
	}
	else {
		print ">$_\n".$ath{$_}."\n";
	}
}
