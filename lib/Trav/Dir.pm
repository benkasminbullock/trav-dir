package Trav::Dir;
use warnings;
use strict;
use Carp;
use utf8;
require Exporter;
our $VERSION = '0.00_01';

sub new
{
    my ($class, %options) = @_;
    my $o;
    if ($options{verbose}) {
	$o->{verbose} = $options{verbose};
	delete $options{verbose};
    }
    if ($options{rejfile}) {
	$o->{rejfile} = $options{rejfile};
	delete $options{rejfile};
    }
    if ($options{no_trav}) {
	$o->{no_trav} = $options{no_trav};
	delete $options{no_trav};
    }
    $o->{minsize} = 0;
    if ($options{minsize}) {
	$o->{minsize} = $options{minsize};
	delete $options{minsize};
    }
    $o->{maxsize} = 'inf';
    if ($options{maxsize}) {
	$o->{maxsize} = $options{maxsize};
	delete $options{maxsize};
    }
    if ($options{only}) {
	$o->{only} = $options{only};
	delete $options{only};
    }
    if ($options{callback}) {
	$o->{callback} = $options{callback};
	delete $options{callback};
    }
    for my $k (keys %options) {
	carp "Unknown option $k";
	delete $options{$k};
    }
    bless $o, $class;
}

sub find_files
{
    my ($o, $dir, $f) = @_;
    my $dh;
    if (! opendir ($dh, $dir)) {
	warn "opendir $dir failed: $!";
	return;
    }
    my @files = readdir ($dh);
    closedir ($dh);
    for my $file (@files) {
	if ($file eq '.' || $file eq '..') {
	    next;
	}
	if ($o->{rejfile} && $file =~ $o->{rejfile}) {
	    if ($o->{verbose}) {
		print "Skipping $file\n";
	    }
	    next;
	}
	my $dfile = "$dir/$file";
	if ($o->{verbose}) {
	    print "$dir $file\n";
	}
	if (-d $dfile) {
	    if (! $o->{no_trav} || $dfile !~ $o->{no_trav}) {
		if (-l $dfile) {
		    # Skip symbolic links
		    if ($o->{verbose}) {
			print "Skipping symbolic link '$dfile'.\n";
		    }
		    next;
		}
		find_files ($o, $dfile, $f);
	    }
	}
	if (-l $dfile) {
	    # Skip symbolic links
	    if ($o->{verbose}) {
		print "Skipping symbolic link '$dfile'.\n";
	    }
	    next;
	}
	my $size = -s $dfile;
	if ($size > $o->{maxsize} || $size < $o->{minsize}) {
	    if ($o->{verbose}) {
		print "Skipping $file due to size $size > $o->{maxsize} or < $o->{minsize}\n";
	    }
	    next;
	}
#	my $safe = $dfile;
#	$safe =~ s![^[:print:]]!XX!g;
#	print "$safe\n";

	if ($o->{only}) {
	    if ($file =~ $o->{only}) {
		$o->save ($f, $dfile);
	    }
	}
	else {
	    $o->save ($f, $dfile);
	}
    }
}

sub save
{
    my ($o, $f, $dfile) = @_;
    push @$f, $dfile;
    if ($o->{callback}) {
	&{$o->{callback}} ($o, $dfile);
    }
}

1;
