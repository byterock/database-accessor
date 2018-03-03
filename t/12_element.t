#!perl
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Element');

}

my $street =
  Database::Accessor::Element->new( { name => 'street', view => 'person', } );
ok( ref($street) eq 'Database::Accessor::Element', "Street is an Element" );
ok(
    does_role( $street, "Database::Accessor::Roles::Base" ) eq 1,
    "View does role Database::Accessor::Roles::Base"
);

ok( $street->aggregate('AvG'), 'can do an Average' );
eval { ok( $street->aggregate('Avgx'), 'can do an Avgx' ); };
if ($@) {
    pass("Element aggregate can not be Avgx");
}
else {
    fail("Element aggregate can not be Avgx");
}
1;
