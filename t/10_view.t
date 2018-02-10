#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use Test::More tests => 3;
use Moose::Util qw(does_role);
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::View');
}

my $view = Database::Accessor::View->new({name  => 'person',alias => 'me'});
ok( ref($view) eq 'Database::Accessor::View', "Person is a View" );
ok( does_role($view,"Database::Accessor::Roles::Base") eq 1,"View does role Database::Accessor::Roles::Base");
ok( $view->name() eq 'person',"Has name Accessor");




