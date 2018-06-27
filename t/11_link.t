#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::More tests => 8;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Link');
}

my $link = Database::Accessor::Link->new(
    {
        type       => 'left',
        to         => { name => 'test' },
        conditions => [
            {
                left => {
                    name => 'field-1',
                    view => 'table-1'
                },
                right => {
                    name => 'field-2',
                    view => 'table-1'
                },
                operator => '='
            }
        ]
    }
);

ok( ref($link) eq 'Database::Accessor::Link', "link is a Link" );


ok( ref( $link->conditions()->[0] ) eq 'Database::Accessor::Condition',
    "Conditions contains a conditiion" );
ok( ref( $link->conditions()->[0]->predicates() ) eq 'Database::Accessor::Predicate',
    "Conditions contains a conditiion" );
    
ok( $link->conditions()->[0]->predicates->operator() eq '=',
    "Condtion->[0]->predicates has operator '='" );

ok( ref($link->to)  eq 'Database::Accessor::View',   "to is a View" );
ok( $link->type  eq 'left',     "type is 'left'" );
1;
