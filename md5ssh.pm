package md5ssh.pm
######################################
# This library is the engine in the md5 file checksum
# program over ssh. 
# Author: Thomas Wiborg
# Date: 21. Feb. 2018
# Version: 0.001 Developement version.
#
# This software is still in prototype stage and
# is missing a lot of production hardning steps.
######################################
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Storable;
use Net::OpenSSH;
use Net::Ping;
use Digest::MD5  qw(md5 md5_hex md5_base64);
use Cwd            qw( abs_path );
use File::Basename qw( dirname );

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw( 
        
);

$VERSION = '0.1';

my %servers;
my $ssh;
die "Cant load configfile\n" unless (LoadHash());

sub CheckHost {
        my ($host) = @_;
        my @ret;
        my $new;
        my $err = Connect($host);
        if ($err) {
                my @data = ListFiles($host);
                foreach my $file (@data) {
                        my $hash = ViewHash("$host:$file");
                        my $stdout = $ssh->capture({stderr_discard => 1}, "cat $file");
                        unless ($?) {
                                $new = md5_hex $stdout;
                                unless ($hash eq $new) {
                                        push(@ret, "$host:$file:$hash:$new");
                                }
                        }
                        else {
                                print "Checkhost Error!! Could not check $host:$file errorcode: $? (" . $ssh->error . ")\n";
                        }
                }
                DisConnect();
                return(@ret);
        }
        else {
                print "Could not connect to $host\n";
                return ('-1');
        }
}

sub ViewHash {
        my ($item) = @_;
        my ($host, $file) = split(/:/, $item);
        if ($servers{$host}{$file}{'md5'}) {
                return ($servers{$host}{$file}{'md5'});
        }
        return();
}

sub ListHosts {
        my @data;
        for my $host (keys %servers) {
                push(@data, $host);
        }
        return(sort @data);
}

sub ListFiles {
        my ($host) = @_;
        my @data;
        for my $files (keys %{$servers{$host}}) {
                push(@data, $files);
        }
        return(sort @data);
}

sub AddFile {
        my ($item) = @_;
        my ($host, $file) = split(/:/, $item);
        return ('-2') unless ($file);
        unless ($servers{$host}{$file}) {
                my $hash = GetMD5($item);
                if ($hash) {
                        $servers{$host}{$file}{'date'} = localtime();
                        $servers{$host}{$file}{'md5'} = $hash;
                        StoreHash();
                        return('1');
                }
        }
        return('-1');
}

sub DelFile {
        my ($item) = @_;
        my ($host, $file) = split(/:/, $item);
        if ($servers{$host}{$file}) {
                delete($servers{$host}{$file});
        }
        StoreHash();
        return();
}

sub DelHost {
        my ($host) = @_;
        if ($servers{$host}) {
                delete($servers{$host});
        }
        StoreHash();
        return();
}

sub StoreHash {
        my $conf = dirname(abs_path($0)) . "/servers.hash";
#       print "-StoreHash- : $conf\n";
        store \%servers, "$conf";
        return();
}

sub LoadHash {
        my $conf = dirname(abs_path($0)) . "/servers.hash";
#       print "-LoadHash- : $conf\n";
        if (-f $conf) {
                %servers = %{retrieve("$conf")};
                return(1);
        }
        return(1);
}

sub GetMD5 {
        my ($item) = @_;
        my ($host, $file) = split(/:/, $item);
        if (Connect($host)) {
                my $stdout = $ssh->capture({stderr_discard => 1}, "cat $file");
                unless ($?) {
                        my $hash = md5_hex $stdout;
                        return($hash);
                }
                DisConnect();
        }
        else {
                print "Could not connect to $host\n";
                return();
        }
}

sub Connect {
        # Needs code to handle exceptions.
        my ($host) = @_;
        return() unless Ping($host);
        my ($user, $pass) = Cred($host);
        $ssh = Net::OpenSSH->new($host, user=>$user, password=>$pass);
        # More connection check code here
        return(1);
}

sub Ping {
        my ($host) = @_;
        my $p = Net::Ping->new("tcp", 7);
        $p->{port_num} = "22";
        $p->{service_check} = "1";
        return() unless $p->ping($host);
        return(1)
}

sub Cred {
        my ($host) = @_;
        # code her for returning username and password.
        return('<username>', '<password'>);
}

sub DisConnect {
#        close $ssh->sock;
        undef $ssh;
        return();
}

sub UpdateFile {
        my ($item) = @_;
        my ($host, $file) = split(/:/, $item);
        if ($servers{$host}{$file}) {
                $servers{$host}{$file}{'date'} = localtime();
                my $hash = GetMD5($item);
                if ($hash) {
                        $servers{$host}{$file}{'md5'} = $hash;
                }
                StoreHash();
                return();
        }
        return('-1');
}

1;
