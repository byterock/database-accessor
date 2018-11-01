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
use Test::Deep;
use Test::Fatal;
use Test::More tests => 24;

my $in_hash ={ view => { name => 'People' },
                                elements => [ { name => 'first_name', }, 
                                               { name => 'last_name', },
                                                { name => 'user_id', },
                                                { name => 'Price'}, ] };
my $da = Database::Accessor->new( $in_hash );


my $gather = {        
       elements => [
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
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People'
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
                    view => 'People'
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
                view => 'People'
            },           
        ],
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => '=',
               
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

$da->reset_gather();
$gather2 = {        
       elements => [
            {
    ifs => [
        {
            left      => { name  => 'Price', },
            right     => { value => '10' },
            operator  => '<',
            then => { name  => 'Price' }
        },
        { then => { param => 'prices' } }
      ]
  }           
        ],
    };
 $da->add_gather($gather2);
 $da->retrieve( Data::Test->new(), $return );
 ok( ref( $da->dynamic_gather()->elements->[0] ) eq "Database::Accessor::If",
    'dynamic_gather()->elements->[0] is a If' );



$da->reset_gather();
$gather2 = {        
       elements => [
            {
              name => 'first_name',
              view => 'People'
            },
            { name => 'user_id',
              view => 'People'
            }
        ],
        view_elements => [
             {
               name => 'first_name',
               view => 'People'
            },
            {
              function => 'count',
              left     => { name => 'user_id',
                            view => 'People'}
            }      
        ],
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => '=',
               
            },
        ]};
 $da->add_gather($gather2);
 $da->retrieve( Data::Test->new(), $return );
 $dad = $da->result->error();
 

 ok( ref($dad->elements->[1] ) eq "Database::Accessor::Function",
    'elements 1 is a function' );
  
  $in_hash->{gather} = $gather;
  
  $da = Database::Accessor->new( $in_hash );
  ok( ref($da->gather) eq "Database::Accessor::Gather",
    'have a static Gather' );
    
  $da->add_gather($gather2);
    
  $da->retrieve( Data::Test->new(), $return );
     ok( ref($da->dynamic_gather) eq "Database::Accessor::Gather",
    'have a dynamic Gather' );
  
   $da->reset_gather();
   
    ok( ref($da->gather) eq "Database::Accessor::Gather",
    'sill have a static Gather' );

  # # $gather2 = {        
       # # elements => [
            # # {
              # # name => 'first_name',
              # # view => 'People'
            # # },
            # # { name => 'salary',
              # # view => 'People'
            # # }
        # # ],
        # # view_elements => [
             # # {
               # # name => 'first_name',
               # # view => 'People'
            # # },
            # # {
               # # name => 'salary',
               # # view => 'People'
            # # }
        # # ],
        # # };
        
 
 
# # like(
    # # exception { $da->add_gather($gather2) },
    # # qr /in not in the elements array! Only elements from that array can be added/,
    # # "Elements not in the elements attribute are not allowed"
# );

1;
