#!/usr/bin/perl
use md5ssh;

my @data = md5ssh::ListHosts();
foreach my $host (@data) {
	print "$host\n";
	my @bata = md5ssh::ListFiles($host);
	foreach my $file(@bata) {
		my $hash = md5ssh::ViewHash("$host:$file");
		my $new = md5ssh::GetMD5("$host:$file");
		if ($hash eq $new) {
			print "\t$file\t$hash ($new)\n";
		}
		else {
			print "\tWarning wrong hash: $file has hash $new but stored with $hash \n";
		}
	}
}
exit;
