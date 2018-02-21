#!/usr/bin/perl
use md5ssh;

my @data = md5ssh::ListHosts();
foreach my $host (@data) {
	print "$host\n";
}
exit;
