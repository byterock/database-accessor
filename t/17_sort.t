#!perl
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 5;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Sort');
}

my $sort = Database::Accessor::Sort->new( { name => 'left', order => 'asc' } );
ok( ref($sort) eq 'Database::Accessor::Sort', "sort is a Sort" );
isa_ok($sort,"Database::Accessor::Base", "sort is a Database::Accessor::Base");
ok( $sort->order eq 'asc', "order is = asc" );
1;
