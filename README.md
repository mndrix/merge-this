Merge This!
===========

About
-----

Merge This! is a test suite for revision control tools designed to stress
test their merge algorithms.  Think of it as
an [Acid3 test](http://acid3.acidtests.org/) for version control systems.

All version control systems have a notion of merging two separate
development branches.  One measure of a VCS's quality is how well
it handles merges.  Is it able to merge two branches without manual
conflict resolution?  Does the code still behave correctly after
automatic resolution?  If a conflict does require manual resolution, how
complicated is the conflict?

Merge This! has a number of small test cases representing typical
development patterns which might cause merge conflicts.  Each VCS
performs the merge and we evaluate the results.  The goal is to
codify many software revision patterns in this fashion.

Each test case contains one small C program.  The branches modify
this program in different ways.  For a test to pass all
of the following must work:

  * VCS automatically merges the two branches (no manual intervention)
  * the C program compiles
  * the compiled C program produces correct output

Failing earlier in this list is better.  The worst possible scenario
is a VCS that silently resolves a merge but does it in a way that
breaks your program at runtime (I hope you have a good test suite :-)

Running the Tests
-----------------

The tests support these tools: bzr, darcs, git, hg.  To test a tool,
run the appropriate make target:

    $ make git

Current Results
---------------

The table of results below is based on these VCS versions:

  * Bazaar - 2.6.0
  * Darcs - 2.10.0
  * Git - 2.5.1
  * Mercurial - 3.5

The tests are sorted by an approximation of how hard they should
be to pass.

|                | Bazaar | Darcs | Git | Mercurial | Subversion |
| -------------- | ------ | ----- | --- | ---------- | ---------- |
| nearby-changes | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) |
| same-change | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) |
| move-modify | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) |
| adjacent-changes | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) |
| trailing-whitespace | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) |
| indent-block | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) |
| indent-block-py | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) |
| eol-comment | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) |
| dual-renames | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![OK](https://raw.githubusercontent.com/mndrix/merge-this/master/img/ok.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) | ![Fail](https://raw.githubusercontent.com/mndrix/merge-this/master/img/fail.png) |
