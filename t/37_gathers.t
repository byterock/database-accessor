#!perl
use strict;
use warnings;
use lib ('t/lib');

use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 16;


my $in_hash = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
    view     => { name => 'People' },
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
    filters => [
        {
            left => {
                name => 'last_name',
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
                name => 'first_name',
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

my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_element( $in_hash->{gathers},
    $da->gathers, $dad->gathers, 'Gather' );
Test::Database::Accessor::Utils::deep_predicate( $in_hash->{filters},
    $da->filters(), $dad->filters(), 'Filters' );

foreach my $type (qw(create update delete)){
   $da->$type( Data::Test->new(), {test=>1} );
   $dad = $da->result->error(); #note to others this is a kludge for testing
   ok($dad->gather_count ==0, "No Gathers on $type");
   ok($dad->filter_count ==0, "No Filters on $type");
}
1;
