#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 16;

my $da = Database::Accessor->new( { view => { name => 'People' },elements => [ { name => 'first_name', }, { name => 'last_name', }, ], } );

my $in_hash = {
    conditions => [
        {
            left => {
                name => 'last_name2',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
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
            open_parentheses  => 0,
            close_parentheses => 1
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
    $dad->conditions(), 'dynamic conditions',1
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
    $dad->conditions, 'Array Dynamic condition',1
);

$return = {};
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to others this is a kludge for testing

ok(
    $da->add_condition( $in_hash->{conditions} ),
    "can add an array Ref of Dynamic conditions"
);

$return = {};
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error(); #note to othe

Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{conditions},   $da->dynamic_conditions,
    $dad->conditions, 'Array Ref Dynamic condition',1
);
1;
