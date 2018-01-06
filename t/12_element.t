#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Element');
}

my $street = Database::Accessor::Element->new({ name => 'street', } );
ok( ref($street) eq 'Database::Accessor::Element', "Street is an Element" );






