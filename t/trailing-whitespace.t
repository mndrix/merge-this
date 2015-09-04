use strict;
use warnings;
use Test::More tests => 8;
use Test::Merges;

# Remove trailing whitespace on the same line as a meaningful change
#
# I see trailing whitespace cause merge conflicts very frequently.
# This is similar to the indent-block test, which affects leading
# whitespace.
#
# A good VCS should notice that trailing whitespace changes are
# independent of other changes on the line.

# build expected output
file 'greet.c', <<'END';
#include <stdio.h>
#include <stdlib.h>
int main () {
    printf("hi\n");  // 4 spaces follow    
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
bye
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/4 spaces follow    /4 spaces follow/', 'greet.c';
    commit 'remove trailing whitespace';
};

branch 'b', sub {
    sed 's/hi/hello/', 'greet.c';
    commit 'longer greeting';
};

merge_ok 'a', 'b';
