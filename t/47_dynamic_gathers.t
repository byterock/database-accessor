#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 19;


my $da = Database::Accessor->new( { view => { name => 'People' } } );


my $gather = {        
       elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
            {
                name => 'last_name',
                view => 'People5'
            },
            {
                name => 'user_id',
                view => 'People6'
            }
        ],
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People7'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 1,
                close_parentheses => 0,
            },
            {
                condition => 'AND',
                left      => {
                    name => 'first_name',
                    view => 'People8'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 0,
                close_parentheses => 1
            }
        ]};


my $gather2 = {        
       elements => [
            {
                name => 'first_name',
                view => 'People4'
            },           
        ],
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People7'
                },
                right             => { value => 'test' },
                operator          => '=',
               
            },
        ]};


ok( $da->add_gather($gather), "can add an single Dynamic gather" );
my $return = {};

$da->retrieve( Data::Test->new(), $return );

my $dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_predicate(
    $gather->{conditions},   $da->dynamic_gather->conditions(),
    $dad->gather->conditions(), 'Dynamic Gather condtions correct'
);

Test::Database::Accessor::Utils::deep_element(
    $gather->{elements},   $da->dynamic_gather->elements(),
    $dad->gather->elements(), 'Dynamic Gather elements correct'
);

$da->add_gather($gather2);
$return = {};

$da->retrieve( Data::Test->new(), $return );

$dad = $da->result->error(); #note to others this is a kludge for testing


Test::Database::Accessor::Utils::deep_predicate(
    $gather2->{conditions},   $da->dynamic_gather->conditions(),
    $dad->gather->conditions(), 'Dynamic Gather 2 condtions correct'
);
Test::Database::Accessor::Utils::deep_element(
    $gather2->{elements},   $da->dynamic_gather->elements(),
    $dad->gather->elements(), 'Dynamic Gather 2 elements correct'
);


1;
