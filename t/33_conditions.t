#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 9;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";
}

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
    conditions => [
        {
            left => {
                name => 'First_1',
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
                name => 'First_2',
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
Test::Database::Accessor::Utils::deep_predicate(
    $in_hash->{conditions}, $da->conditions(),
    $dad->conditions(),     'conditions'
);

my $in_hash3 = {
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
    conditions => {
        left => {
            name => 'second_1',
            view => 'People'
        },
        right           => { value => 'test' },
        operator        => '=',
        open_parentheses  => 1,
        close_parentheses => 0,
        condition       => 'AND',
    },
};
my $da2 = Database::Accessor->new($in_hash3);

ok( ref( $da2->conditions()->[0] ) eq "Database::Accessor::Condition",
    'DA has a condtion' );
ok( scalar( @{ $da2->conditions() } ) == 1, 'DA has only 1 condtion' );
ok( scalar( @{ $da2->conditions()->[0]->predicates } ) == 1,
    'DA has only 1 predicate' );
ok(
    ref( $da2->conditions()->[0]->predicates->[0] ) eq
      "Database::Accessor::Predicate",
    'DA has a condtion predicate is a predicate'
);
1;
