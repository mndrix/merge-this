use strict;
use warnings;
use Test::More tests => 2;
use Test::Merges;

# Add an end-of-line comment and change the same line
#
# Developers sometimes add comments to a block of code when they
# encounter it for the first time.  It's a good opportunity to
# document subtle assumptions.  When this is done with end of line
# comments, conflicts can result.
#
# A good VCS should notice that an end of line comment is independent
# of changes earlier on the line.  This might require knowing a language's
# semantics to get it right.

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
hello
bye
END

# build a common starting point
add 'greet.c', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    file 'greet.c', <<'END';
#include <stdio.h>
#include <stdlib.h>
int main () {
    printf("hi\n"); // greet the user
    printf("bye\n");
    exit(0);
}
END
    commit 'add eol comment';
};

branch 'b', sub {
    sed 's/hi/hello/', 'greet.c';
    commit 'longer greeting';
};

merge_ok 'a', 'b';
