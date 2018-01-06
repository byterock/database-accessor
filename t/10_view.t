#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::View');
}

my $view = Database::Accessor::View->new({name  => 'person',alias => 'me'});

ok( ref($view) eq 'Database::Accessor::View', "Person is a View" );




