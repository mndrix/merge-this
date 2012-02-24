package Test::Merges;
use strict;
use warnings;
use feature qw( switch );
use autodie qw( system );

use base 'Exporter';

our ( @EXPORT, $repository_dir );
BEGIN {
    @EXPORT = qw{
        add
        branch
        commit
        file
        merge
        sed
        replace
        move
    };
}

sub import {
    my ($class) = @_;
    system "rm -rf repos";
    mkdir 'repos';
    chdir 'repos';
    mkdir 'initial';
    chdir 'initial';
    init();

    $class->export_to_level(1, @_);
}

sub file {
    my ($name, $content) = @_;

    open my $fh, '>', $name;
    print $fh $content;
    close $fh;
}

################# Repository actions ###################

# initialize a repository in the current directory
sub init {
    given($ENV{VCS}) {
        when('darcs') { system "darcs init" }
        when('git')   { system "git init" }
        when('hg')    { system "hg init" }
        default       { die "Must specify VCS environment\n" }
    }
}

# tell VCS to track some files
sub add {
    my @files = @_;
    given($ENV{VCS}) {
        when('darcs') { system "darcs add @files" }
        when('git')   { system "git add @files" }
        when('hg')    { system "hg  add @files" }
    }
}

# commits all changes made to the current repository
sub commit {
    my ($message) = @_;
    given($ENV{VCS}) {
        when('darcs') {
            system "darcs record -a --skip-long-comment -m '$message'"
        }
        when('git') { system "git commit -a -m '$message'" }
        when('hg')  { system "hg  commit -m '$message'" }
    }
}

# create a new repository from an existing one
sub clone {
    my ($source,$target) = @_;
    given($ENV{VCS}) {
        when('darcs') {
            system "darcs get --set-scripts-executable $source $target"
        }
        when('git') { system "git clone $source $target" }
        when('hg')  { system "hg  clone $source $target" }
    }
}

# operate on the named branch, creating it if necessary
sub branch {
    my ( $name, $operation ) = @_;
    chdir '..';
    if ( not -d $name ) {
        clone 'initial', $name;
    }
    chdir $name;
    $operation->();
    chdir '../initial';
}

# low-level operation to merge one repository into the current repository
sub perform_merge {
    my ($source) = @_;
    given($ENV{VCS}) {
        when('darcs') {
            system "darcs pull -a"
                 . " --no-allow-conflicts"
                 . " --no-set-default $source"
                 ;
        }
        when('git') { system "git pull --no-ff -q $source master" }
        when('hg')  {
            system "hg pull $source";
            system "hg merge";
            system "hg commit -m 'merged from $source'";
        }
    }
}

sub merge {
    my ( $x, $y ) = @_;
    chdir '..';

    # test merges in both directions (some VCS have asymmetric merges)
    for my $combo ( [$x,$y], [$y,$x] ) {
        my ($x,$y) = @$combo;
        my $repo_name = "merge-$y-into-$x";
        clone $x, $repo_name;
        chdir $repo_name;
        perform_merge("../$y");
        system("./run > obtained.txt");
        system("diff -u expected.txt obtained.txt");
        chdir '..';
    }
}

# apply a sed script to a file, modifying it in-place
sub sed {
    my ($script, $file) = @_;
    system "sed -i '' '$script' $file";
}

# perform search and replace across an entire file
sub replace {
    my ( $old, $new, $file ) = @_;
    given($ENV{VCS}) {
        when('darcs') { system "darcs replace '$old' '$new' $file" }
        default       { sed "s/$old/$new/g", $file }
    }
}

# moves a file from one location to another (also used for renaming)
sub move {
    my ($old,$new) = @_;
    given($ENV{VCS}) {
        when('darcs') { system "darcs move $old $new" }
        when('git')   { system "git   mv   $old $new" }
        when('hg')    { system "hg    mv   $old $new" }
    }
}

1;
