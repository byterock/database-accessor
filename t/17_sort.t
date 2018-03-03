#!perl
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 3;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Sort');
}

my $sort = Database::Accessor::Sort->new( { name => 'left', order => 'asc' } );
warn();
ok( ref($sort) eq 'Database::Accessor::Sort', "sort is a Sort" );
ok(
    does_role( $sort, "Database::Accessor::Roles::Base" ) eq 1,
    "sort does role Database::Accessor::Roles::Base"
);
ok( $sort->order eq 'asc', "order is = asc" );
1;
