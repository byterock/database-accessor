#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 23;

my $in_hash = {
    view     => { name => 'People' },
    elements => [
        {
            name  => 'first_name',
            view  => 'People',
            alias => 'user'
        },
        {
            name  => 'last_name',
            view  => 'People',
            alias => 'user'
        },
        {
            name  => 'user_id',
            view  => 'People',
            alias => 'user'
        },
    ],
};

my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing

foreach my $element ( @{ $in_hash->{elements} } ) {
    ok( $da->add_element($element), "can add an single Dynamic element" );
}

$da->retrieve( Data::Test->new(), {} );

Test::Database::Accessor::Utils::deep_element(
    $in_hash->{elements}, $da->dynamic_elements,
    $dad->elements,       'Single Dynamic Element'
);

ok(
    $da->add_element( @{ $in_hash->{elements} } ),
    "can add an array of Dynamic elements"
);

$da->retrieve( Data::Test->new(), {} );
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_element(
    $in_hash->{elements}, $da->dynamic_elements,
    $dad->elements,       'Array Dynamic Element'
);

ok(
    $da->add_element( $in_hash->{elements} ),
    "can add an ref array of Dynamic elements"
);

$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_element(
    $in_hash->{elements}, $da->dynamic_elements,
    $dad->elements,       'Array Dynamic Element'
);
1;
