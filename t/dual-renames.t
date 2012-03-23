use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# One branch renames a function.  The other branch renames that function's
# parameter.
#
# Renaming identifiers is a common cause of merge conflicts.  I've heard many
# people advise against variable renaming (even if it makes the code clearer)
# out of fear of conflicts down the road.
#
# An ideal VCS would handle simultaneous renaming as long as the two branches
# rename different identifiers.  Unfortunately, ideal VCSs are rare.

# build expected output
file 'hello.c', <<'END';
#include <stdio.h>
#include <stdlib.h>

void hello(char *nm) {
    printf("Hello, %s!\n", nm);
}

int main () {
    hello("John");
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
Hello, John!
END

# build a common starting point
add 'hello.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    replace 'hello', 'greet', 'hello.c';
    commit 'change hello() to greet()';
};

branch 'b', sub {
    replace 'nm', 'name', 'hello.c';
    commit 'more descriptive parameter for hello()';
};

merge_ok 'a', 'b';
