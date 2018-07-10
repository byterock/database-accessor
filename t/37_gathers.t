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

use Test::More tests => 12;



BEGIN {
    use_ok('Database::Accessor::Gather');
}

my $gather = Database::Accessor::Gather->new( { elements => [
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
                open_parentheses  => 1,
                close_parentheses => 0,
                condition         => 'AND',
            },
        ]
      });
ok( ref($gather) eq 'Database::Accessor::Gather', "gather is a Gather" );
isa_ok($gather,"Database::Accessor::Base", "Gather is a Database::Accessor::Base");



my $in_hash = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
    view                      => { name => 'People' },
    elements                  => [
        {
            name => 'first_name',
            view => 'People1'
        },
        {
            name => 'last_name',
            view => 'People2'
        },
        {
            name => 'user_id',
            view => 'People3'
        }
    ],
    gather => {
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
                condition         => 'AND',
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
        ]
      },
  };

my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing


Test::Database::Accessor::Utils::deep_element( $in_hash->{gather}->{elements},
    $da->gather->elements, $dad->gather->elements, 'Gather' );
foreach my $type (qw(create update delete)){
   $da->$type( Data::Test->new(), {test=>1} );
   $dad = $da->result->error(); #note to others this is a kludge for testing
   ok(!$dad->gather_count, "No Gathers on $type");
  
}
1;
