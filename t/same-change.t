use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# Perform the exact same change in two separate branches.
#
# This pattern isn't terribly common, but I've seen it a few times.  It occurs
# more frequently when two branches apply a common third-party patch.
#
# A good VCS should notice that the changes are identical and allow them to
# proceed without conflict.

# build expected output
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
hi
see ya
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/bye/see ya/', 'greet.c';
    commit 'say goodbye';
};

branch 'b', sub {
    sed 's/bye/see ya/', 'greet.c';
    commit 'add a matching farewell';
};

merge_ok 'a', 'b';
