#!perl 
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 3;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Param');
}

my $param = Database::Accessor::Param->new( { name => 'right', param => 22 } );

ok( ref($param) eq 'Database::Accessor::Param', "param is a Param" );
ok(
    does_role( $param, "Database::Accessor::Roles::Base" ) eq 1,
    "Param does role Database::Accessor::Roles::Base"
);
ok( $param->value() == 22, 'Value = 22' );
ok( $param->param() == 22, 'param = 22' );
1;
