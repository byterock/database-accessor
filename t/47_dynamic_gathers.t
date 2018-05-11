#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 26;


my $da = Database::Accessor->new( { view => { name => 'People' } } );

my $in_hash = {
    gathers => [
        {
            name => 'first_name',
            view => 'People'
        },
        {
            name => 'last_name',
            view => 'People'
        },
        {
            name => 'user_id',
            view => 'People'
        }
    ],

};

foreach my $gather ( @{ $in_hash->{gathers} } ) {
    ok( $da->add_gather($gather), "can add an single Dynamic gather" );
}
my $return = {};
$da->retrieve( Data::Test->new(), $return );

my $dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_element(
    $in_hash->{gathers},   $da->dynamic_gathers,
    $dad->gathers, 'Dynamic Gather'
);

$da = Database::Accessor->new( { view => { name => 'People' } } );

ok(
    $da->add_gather( $in_hash->{gathers} ),
    "can add an array of Dynamic gathers"
);

$in_hash = {
    filters => [
        {
            left => {
                name => 'last_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parenthes  => 1,
            close_parenthes => 0,
            condition       => 'AND',
        },
        {
            condition => 'AND',
            left      => {
                name => 'first_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parenthes  => 0,
            close_parenthes => 1
        }
    ]
};

$da = Database::Accessor->new( { view => { name => 'People' } } );

foreach my $filter ( @{ $in_hash->{filters} } ) {
    ok( $da->add_filter($filter), "can add an single Dynamic filter" );
}

$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{filters},     $da->dynamic_filters(),
    $dad->filters(), 'dynamic filters'
);

$da = Database::Accessor->new( { view => { name => 'People' } } );

ok(
    $da->add_filter( $in_hash->{filters} ),
    "can add an array ref of Dynamic filters"
);

$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{filters},     $da->dynamic_filters(),
    $dad->filters(), 'array ref of dynamic filters'
);

$da = Database::Accessor->new( { view => { name => 'People' } } );

ok(
    $da->add_filter( @{ $in_hash->{filters} } ),
    "can add an array of Dynamic filters"
);

$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{filters},     $da->dynamic_filters(),
    $dad->filters(), 'Array of dynamic filters'
);
1;
