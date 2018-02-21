#!/usr/bin/perl
use md5ssh;

my @data = md5ssh::ListHosts();
foreach my $host (@data) {
	my @files = md5ssh::ListFiles($host);
	foreach my $file (@files) {
		print "$host:$file:" . md5ssh::ViewHash("$host:$file") . "\n";
	}
}
