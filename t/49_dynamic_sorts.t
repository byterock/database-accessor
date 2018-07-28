#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);;
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 23;


my $in_hash = {
    sorts => [
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

my $da = Database::Accessor->new( { view => { name => 'People' },elements => [ { name => 'first_name', }, { name => 'last_name', }, ] } );

foreach my $sort ( @{ $in_hash->{sorts} } ) {
    ok( $da->add_sort($sort), "can add an single Dynamic sort" );
}

# warn("DA 1=".Dumper($da));
my $return_str = {};
$da->retrieve( Data::Test->new(), $return_str );

my $dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->sorts, 'dynamic sorts'
);

ok(
    $da->add_sort( @{ $in_hash->{sort} } ),
    "can add an Array of Dynamic sorts"
);

$da->retrieve( Data::Test->new(), $return_str );
$dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->sorts, 'Array of dynamic sorts'
);

ok( $da->add_sort( $in_hash->{sort} ),
    "can add an Array Ref of Dynamic sorts" );

$dad = $da->retrieve( Data::Test->new(), $return_str );
$dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->sorts, 'Array Ref of dynamic sorts'
);
