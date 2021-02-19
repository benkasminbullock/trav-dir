#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin '$Bin';
use Trav::Dir;
my @files;
my $o = Trav::Dir->new ();
$o->find_files ("$Bin/..", \@files);
print $files[ int (rand (scalar (@files))) ];
