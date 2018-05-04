#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 16;

my $da = Database::Accessor->new( { view => { name => 'People' } } );

my $in_hash = {
    conditions => [
        {
            left => {
                name => 'last_name2',
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
                name => 'first_name3',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parenthes  => 0,
            close_parenthes => 1
        }
      ]

    ,
};

foreach my $condition ( @{ $in_hash->{conditions} } ) {
    ok( $da->add_condition($condition), "can add an single Dynamic condition" );

}
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{conditions},     $da->dynamic_conditions(),
    $dad->dynamic_conditions(), 'dynamic conditions'
);

$return = {};
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

ok(
    $da->add_condition( @{ $in_hash->{conditions} } ),
    "can add an array of Dynamic conditions"
);

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{conditions},   $da->dynamic_conditions,
    $dad->dynamic_conditions, 'Array Dynamic condition'
);

$return = {};
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

ok(
    $da->add_condition( $in_hash->{conditions} ),
    "can add an array Ref of Dynamic conditions"
);

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{conditions},   $da->dynamic_conditions,
    $dad->dynamic_conditions, 'Array Ref Dynamic condition'
);
1;
