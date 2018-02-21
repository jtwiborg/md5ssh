#!/usr/bin/perl
use md5ssh;

die "Usage: $0 <host>\n" unless @ARGV == 1;
my $host = shift;
	
my @bata = md5ssh::CheckHost($host);
foreach my $ret(@bata) {
	my ($hst, $f, $h, $n) = split(/:/, $ret);
	print "Checksum Errors: $ret\n";
  # Too update file:	md5ssh::UpdateFile("$host:$f");
}
exit;
