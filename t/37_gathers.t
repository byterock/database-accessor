#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 10;


my $in_hash = {
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


1;
