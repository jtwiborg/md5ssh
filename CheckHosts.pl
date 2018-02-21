#!/usr/bin/perl
use md5ssh;

my @data = md5ssh::ListHosts();
foreach my $host (@data) {
	print "$host\n";
	my @bata = md5ssh::CheckHost($host);
	next unless (@bata);
	foreach my $ret(@bata) {
		my ($hst, $f, $h, $n) = split(/:/, $ret);
		print "Checksum Errors: $ret\n";
    # If files should be updated:	md5ssh::UpdateFile("$host:$f");
	}
}
exit;
