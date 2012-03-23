use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# Perform two changes on nearby lines
#
# This pattern often occurs when one developer updates comments
# and another modifies nearby code.
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
    exit(0);   /* exit with suces */
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
bye
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/suces/success/', 'greet.c';
    commit 'correct comment typo';
};

branch 'b', sub {
    sed 's/hi/hello/', 'greet.c';
    commit 'more formal greeting';
};

merge_ok 'a', 'b';
