use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# Perform two changes on immediately adjacent lines.
#
# This pattern seems to occur slightly less frequently than "random" changes
# because many languages have curly braces which offer natural separators
# for adjacent code.  I have no data, but I suspect this kind of change is
# more common in Python or Haskell which use indentation instead of braces.
#
# A good VCS should apply both changes without conflict.  They clearly don't
# conflict since they don't modify the same lines.

# program to generate expected output
file 'greet.c', <<'END';
#include <stdio.h>
#include <stdlib.h>
int main () {
    printf("hi\n");
    printf("bye\n");
    exit(0);
}
END

file 'run', <<'END';
#!/bin/sh
gcc -o greet greet.c && \
./greet
END
chmod 0755, 'run';

# expected output after all merges are done
file 'expected.txt', <<'END';
hello
goodbye
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/bye/goodbye/', 'greet.c';
    commit 'say goodbye';
};

branch 'b', sub {
    sed 's/hi/hello/', 'greet.c';
    commit 'more formal greeting';
};

merge_ok 'a', 'b';
