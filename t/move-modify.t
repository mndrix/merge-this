use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# One branch moves a file.  Another branch modifies the file.
#
# This pattern is fairly common during project reorganization. Files are moved
# around the directory tree in the reorg branch, while development proceeds
# apace in the other branch.
#
# A good VCS applies modifications to the file in its new location without
# conflict.

# build expected output
file 'hello.c', <<'END';
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
gcc -o hello hello.c && \
./hello
END
chmod 0755, 'run';

# expected output after all merges are done
file 'expected.txt', <<'END';
hi
goodbye
END

# build a common starting point
add 'hello.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    move 'hello.c', 'greet.c';
    replace 'hello', 'greet', 'run';
    commit 'renaming hello script to greet';
};

branch 'b', sub {
    sed 's/bye/goodbye/', 'hello.c';
    commit 'more expressive farewell';
};

merge_ok 'a', 'b';
