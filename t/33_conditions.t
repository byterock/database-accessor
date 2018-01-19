#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;

BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}


my $da = Database::Accessor->new({view=>{name=>'test'}});


