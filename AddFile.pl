#!/usr/bin/perl
use md5ssh;

die "Usage: $0 <host>:<file>\n" unless @ARGV == 1;
my $item = shift;

md5ssh::AddFile($item);
exit;
