#!perl
use Test::More 0.82;
use Test::Fatal;
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Test::More tests => 6;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Element');

}

my $street =
  Database::Accessor::Element->new( { name => 'street', view => 'person', } );
ok( ref($street) eq 'Database::Accessor::Element', "Street is an Element" );
ok(
    does_role( $street, "Database::Accessor::Roles::Alias" ) eq 1,
    "View does role Database::Accessor::Roles::Alias"
);
ok( $street->aggregate('AvG'), 'can do an Average' );
like(
   exception {$street->aggregate('Avgx');},
   qr/Attribute \(aggregate\) does not pass the type constraint because/,
 "the code died as expected with Avgx",
);
1;
