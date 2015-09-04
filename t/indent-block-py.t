use strict;
use warnings;
use Test::More tests => 8;
use Test::Merges;

# indent-block in Python
#
# Python's syntax is sensitive to indentation so it's more
# likely to fail this test than C.

# program to generate expected output
file 'greet.py', <<'END';
# greeting
print("hi")

# farewell
print("bye")
END

file 'run', <<'END';
#!/bin/sh
python greet.py
END
chmod 0755, 'run';

# expected output after all merges are done
file 'expected.txt', <<'END';
hello
bye
END

# build a common starting point
add 'greet.py', 'run', 'expected.txt';
commit 'intial state';

branch 'a', sub {
    sed 's/hi/hello/', 'greet.py';
    commit 'say hello';
};

branch 'b', sub {
    file 'greet.py', <<'END';
if True:
    # greeting
    print("hi")

    # farewell
    print("bye")
END

    commit 'add an if';
};

merge_ok 'a', 'b';
