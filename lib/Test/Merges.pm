package Test::Merges;
use strict;
use warnings;
use Cwd;
use File::Basename;
use experimental qw( switch );
use autodie qw( system );
use base qw( Exporter Test::Builder::Module );

use Try::Tiny;

our ( @EXPORT, $repository_dir );

BEGIN {
    @EXPORT = qw{
      add
      branch
      commit
      file
      merge_ok
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

    $class->export_to_level( 1, @_ );
}

sub pass {
    my ($name) = @_;
    __PACKAGE__->builder->ok( 1, $name );
}

sub fail {
    my ($name) = @_;
    __PACKAGE__->builder->ok( 0, $name );
}

sub file {
    my ( $name, $content ) = @_;

    open my $fh, '>', $name;
    print $fh $content;
    close $fh;
}

################# Repository actions ###################

# initialize a repository in the current directory
sub init {
    given ( $ENV{VCS} ) {
        when ('bzr')   { system "bzr init" }
        when ('darcs') { system "darcs init" }
        when ('git')   { system "git init" }
        when ('hg')    { system "hg init" }
        when ('svn')    {
            chdir '..';
            my $dir = getcwd;
            system "svnadmin create ./svnrepo";
            system "svn mkdir -m 'initialize' file://${dir}/svnrepo/initial";
            system "svn checkout file://${dir}/svnrepo/initial initial";
            chdir 'initial';
        }
        default        { die "Must specify VCS environment\n" }
    }
}

# tell VCS to track some files
sub add {
    my @files = @_;
    given ( $ENV{VCS} ) {
        when ('bzr')   { system "bzr add @files" }
        when ('darcs') { system "darcs add @files" }
        when ('git')   { system "git add @files" }
        when ('hg')    { system "hg  add @files" }
        when ('svn')    {
            system "svn update";
            system "svn add @files";
        }
    }
}

# commits all changes made to the current repository
sub commit {
    my ($message) = @_;
    given ( $ENV{VCS} ) {
        when ('bzr') { system "bzr commit --quiet -m '$message'" }
        when ('darcs') {
            system "darcs record -a --skip-long-comment -m '$message'"
        }
        when ('git') { system "git commit -a -m '$message'" }
        when ('hg')  { system "hg  commit -m '$message'" }
        when ('svn')    {
            system "svn update";
            system "svn --non-interactive commit -m '$message'";
        }
    }
}

# create a new repository from an existing one
sub clone {
    my ( $source, $target ) = @_;
    given ( $ENV{VCS} ) {
        when ('bzr') { system "bzr branch $source $target" }
        when ('darcs') {
            system "darcs get --quiet --set-scripts-executable $source $target"
        }
        when ('git') { system "git clone --quiet $source $target" }
        when ('hg')  { system "hg  clone $source $target" }
        when ('svn')  {
            my $dir = getcwd;
            print "svn clone ${source} to ${target}\n";
            system "svn copy -m 'branch created' file://${dir}/svnrepo/${source} file://${dir}/svnrepo/${target}";
            system "svn checkout file://${dir}/svnrepo/${target} ${target}";
        }
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
    given ( $ENV{VCS} ) {
        when ('bzr') {
            my $algo = $ENV{MERGE} // 'merge3';
            my $show_base = $algo eq 'merge3' ? "--show-base" : "--reprocess";
            system "bzr merge --merge-type=$algo $show_base $source"
        }
        when ('darcs') {
            system "darcs pull -a"
              . " --mark-conflicts"
              . " --no-set-default $source";
        }
        when ('git') {
            system "git pull --no-ff -Xignore-all-space -q $source master"
        }
        when ('hg') {
            system "hg pull $source";
            system "hg merge --tool internal:merge";
            commit "merged from $source";
        }
        when ('svn') {
            my $current_repo_dir=getcwd;
            my $current_repo = basename($current_repo_dir);
            my $source_repo = basename($source);
            print "svn merge from $source_repo to $current_repo\n";
            chdir '..';
            my $dir = getcwd;
            chdir "$current_repo";
            system 'svn update';
            system "svn --non-interactive -x --ignore-all-space merge file://${dir}/svnrepo/${source_repo}";
            commit "merged from $source_repo";
        }
    }
}

sub merge_ok {
    my ( $x, $y ) = @_;
    chdir '..';

    # test merges in both directions (some VCS have asymmetric merges)
    for my $combo ( [ $x, $y ], [ $y, $x ] ) {
        my ( $x, $y ) = @$combo;
        my $repo_name = "merge-$y-into-$x";
        clone $x, $repo_name;
        chdir $repo_name;

        my @phases = qw( merge run output );
        my $check  = sub {
            my $phase = shift @phases;
            pass("$phase ($y into $x)");
        };
        try {
            perform_merge("../$y");
            $check->();
            system("./run > obtained.txt");
            $check->();
            system("diff -u expected.txt obtained.txt");
            $check->();
            pass("$y into $x");
        }
        catch {
            fail($_) for @phases;
            fail("$y into $x");
        };
        chdir '..';
    }
}

# apply a sed script to a file, modifying it in-place
sub sed {
    my ( $script, $file ) = @_;
    system "sed -ibak '$script' $file";
}

# perform search and replace across an entire file
sub replace {
    my ( $old, $new, $file ) = @_;
    given ( $ENV{VCS} ) {
        when ('darcs') { system "darcs replace '$old' '$new' $file" }
        default { sed "s/$old/$new/g", $file }
    }
}

# moves a file from one location to another (also used for renaming)
sub move {
    my ( $old, $new ) = @_;
    given ( $ENV{VCS} ) {
        when ('bzr')   { system "bzr   mv   $old $new" }
        when ('darcs') { system "darcs move $old $new" }
        when ('git')   { system "git   mv   $old $new" }
        when ('hg')    { system "hg    mv   $old $new" }
        when ('svn')   { system "svn   move   $old $new" }
    }
}

1;
