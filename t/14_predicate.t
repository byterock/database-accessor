#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Predicate');
}

my $predicate = Database::Accessor::Predicate->new({name  => 'name',left=> {name=>'left'},right=>{name=>'right'}});

ok( ref($predicate) eq 'Database::Accessor::Predicate', "predicate is a Predicate" );






