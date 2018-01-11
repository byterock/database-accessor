#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;
use Moose::Util qw(does_role);
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Param');
}

my $param = Database::Accessor::Param->new({name=>'right'});

ok( ref($param) eq 'Database::Accessor::Param', "param is a Param" );
ok( does_role($param,"Database::Accessor::Roles::Base") eq 1,"Param does role Database::Accessor::Roles::Base");
eval{
   warn("rtest=".$param->alias());
};
if ($@){
  pass("Param cannot alias");
}
else {
   fail("Param cannot alias");
}





