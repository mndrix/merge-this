use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# Modify and indent a block of code
#
# One branch modifies a line within a block of code.  The other branch indents
# that same block.  I see this pattern quite frequently in shared library code
# where one developer is correcting a bug in a feature while another developer
# makes that same feature optional, for example.
#
# An excellent VCS would recognize that the indent operation didn't change the
# content at all.  It should be able to apply both changes without ambiguity.

# program to generate expected output
file 'greet.c', <<'END';
#include <stdio.h>
#include <stdlib.h>
int main () {
    /* greeting */
    printf("hi\n");

    /* farewell */
    printf("bye\n");

    /* all went well */
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
bye
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/hi/hello/', 'greet.c';
    commit 'say hello';
};

branch 'b', sub {
    file 'greet.c', <<'END';
#include <stdio.h>
#include <stdlib.h>
int main () {
    if (1) {
        /* greeting */
        printf("hi\n");

        /* farewell */
        printf("bye\n");
    }

    /* all went well */
    exit(0);
}
END

    commit 'add an if';
};

merge_ok 'a', 'b';
