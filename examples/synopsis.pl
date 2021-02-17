#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin '$Bin';
use Trav::Dir;
my $o = Trav::Dir->new (
    # Don't traverse these directories
    no_trav => qr!/(\.git|xt|blib)$!,
    # Reject these files
    rejfile => qr!~$|MYMETA|\.tar\.gz!,
);
my @files;
chdir "$Bin/..";
$o->find_files (".", \@files);
for (@files) {
    if (-f $_) {
	print "$_\n";
    }
}
