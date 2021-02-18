package Trav::Dir;
use warnings;
use strict;
use Carp;
use utf8;
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
	$o->{size} = 1;
    }
    $o->{maxsize} = 'inf';
    if ($options{maxsize}) {
	$o->{maxsize} = $options{maxsize};
	delete $options{maxsize};
	$o->{size} = 1;
    }
    if ($options{only}) {
	$o->{only} = $options{only};
	delete $options{only};
    }
    if ($options{callback}) {
	$o->{callback} = $options{callback};
	delete $options{callback};
    }
    if ($options{no_dir}) {
	$o->{no_dir} = $options{no_dir};
	delete $options{no_dir};
    }
    if ($options{data}) {
	$o->{data} = $options{data};
	delete $options{data};
    }
    if ($options{preprocess}) {
	$o->{preprocess} = $options{preprocess};
	delete $options{preprocess};
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
    if (! $f && ! $o->{callback}) {
	# There is no work for us to do
	carp "No file list and no callback";
	return;
    }
    my $dh;
    if (! opendir ($dh, $dir)) {
	warn "opendir $dir failed: $!";
	return;
    }
    my @files = readdir ($dh);
    closedir ($dh);
    if ($o->{preprocess}) {
	&{$o->{preprocess}} ($o->{data}, $dir, \@files);
    }
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
	my $is_dir = 0;
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
	    if ($o->{no_dir}) {
		next;
	    }
	    $is_dir = 1;
	}
	if (-l $dfile) {
	    # Skip symbolic links
	    if ($o->{verbose}) {
		print "Skipping symbolic link '$dfile'.\n";
	    }
	    next;
	}
	if (! $is_dir && $o->{size}) {
	    my $size = -s $dfile;
	    if ($size > $o->{maxsize} || $size < $o->{minsize}) {
		if ($o->{verbose}) {
		    print "Skipping $file due to size $size > $o->{maxsize} or < $o->{minsize}\n";
		}
		next;
	    }
	}
	#	my $safe = $dfile;
	#	$safe =~ s![^[:print:]]!XX!g;
	#	print "$safe\n";

	if (! $o->{only} || $file =~ $o->{only}) {
	    $o->save ($dfile, $f);
	}
    }
}

sub save
{
    my ($o, $dfile, $f) = @_;
    if ($f) {
	push @$f, $dfile;
    }
    if ($o->{callback}) {
	&{$o->{callback}} ($o->{data}, $dfile);
    }
}

1;
