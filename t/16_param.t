#!perl

use Test::More tests => 6;
use Moose::Util qw(does_role);
use lib ('..\lib');
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Param');
}

my $param = Database::Accessor::Param->new( { name => 'right', param => 22 } );

ok( ref($param) eq 'Database::Accessor::Param', "param is a Param" );
isa_ok($param,"Database::Accessor::Base", "Param is a Database::Accessor::Base");
ok( $param->value() == 22, 'Value = 22' );
ok( $param->param() == 22, 'param = 22' );
1;
