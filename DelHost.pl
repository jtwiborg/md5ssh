#!/usr/bin/perl
use md5ssh;

die "Usage: $0 <host>\n" unless @ARGV == 1;
my $item = shift;
md5ssh::DelHost($item);
exit;
