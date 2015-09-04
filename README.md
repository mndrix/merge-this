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

<table>
    <thead>
        <tr>
            <th></th>
            <th>Bazaar</th>
            <th>Darcs</th>
            <th>Git</th>
            <th>Mercurial</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>adjacent-changes</th>
            <td>Fail</td>
            <td>Ok</td>
            <td>Fail</td>
            <td>Fail</td>
        </tr>
        <tr>
            <th>dual-renames</th>
            <td>Fail</td>
            <td>Ok</td>
            <td>Fail</td>
            <td>Fail</td>
        </tr>
        <tr>
            <th>indent-block</th>
            <td>Fail</td>
            <td>Fail</td>
            <td>Ok</td>
            <td>Fail</td>
        </tr>
        <tr>
            <th>trailing-whitespace</th>
            <td>Fail</td>
            <td>Fail</td>
            <td>Ok</td>
            <td>Fail</td>
        </tr>
        <tr>
            <th>eol-comment</th>
            <td>Fail</td>
            <td>Fail</td>
            <td>Fail</td>
            <td>Fail</td>
        </tr>
        <tr>
            <th>move-modify</th>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
        </tr>
        <tr>
            <th>nearby-changes</th>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
        </tr>
        <tr>
            <th>same-change</th>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
            <td>Ok</td>
        </tr>
    </tbody>
</table>
