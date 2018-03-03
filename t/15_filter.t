#!perl
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 3;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Filter');
}

my $filter = Database::Accessor::Filter->new( { name => 'left' } );

ok( ref($filter) eq 'Database::Accessor::Filter', "filter is a Filter" );
ok(
    does_role( $filter, "Database::Accessor::Roles::Base" ) eq 1,
    "filter does role Database::Accessor::Roles::Base"
);
1;
