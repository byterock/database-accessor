#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 5;
use Moose::Util qw(does_role);
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Link');
}

my $link = Database::Accessor::Link->new({name=>'new',left=> {name=>'left'},right=>{name=>'right'}});

ok( ref($link) eq 'Database::Accessor::Link', "link is a Link" );
ok( does_role($link,"Database::Accessor::Roles::Base") eq 1,"link does role Database::Accessor::Roles::Base");
eval{
   $link->alias();
};
if ($@){
  fail("Link cannot alias");
}
else {
   pass("Link cannot alias");
}





