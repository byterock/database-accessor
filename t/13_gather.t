#!perl 
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 3;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Gather');
}

my $gather = Database::Accessor::Gather->new(
    { left => { name => 'left' }, right => { name => 'right' } } );

ok( ref($gather) eq 'Database::Accessor::Gather', "gather is a Gather" );
ok(
    does_role( $gather, "Database::Accessor::Roles::Base" ) eq 1,
    "gather does role Database::Accessor::Roles::Base"
);
