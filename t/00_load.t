#!perl 
use Test::More 0.82;

use Test::More tests => 1;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";
}
1;
