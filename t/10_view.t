#!perl
use Test::More 0.82;
use lib ('..\t\lib');
use lib ('..\lib');
use Test::More tests => 8;
use Test::Fatal;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::View');
}

my $view =
  Database::Accessor::View->new( { name => 'person', alias => 'test' } );
ok( ref($view) eq 'Database::Accessor::View', "Person is a View" );
ok(
    does_role( $view, "Database::Accessor::Roles::Alias" ) eq 1,
    "View does role Database::Accessor::Roles::Alias"
);
ok( $view->name()  eq 'person', "Has name Accessor" );
ok( $view->alias() eq 'test',   "Has alias Accessor" );

like(
    exception { Database::Accessor::View->new( { alias => 'person' } ) },
    qr /Attribute \(name\) is required/,
    "attribute name is a requied field"
);

is( exception { Database::Accessor::View->new( { name => 'person' } ) },
    undef, "attribute alias is not a requied field" );
