#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 12;


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
        },
        {
            name => 'name',
            view => 'country'
        }
    ],

    links => [
        {
            to => {
                name  => 'Hash_1_link',
                alias => 'a_country'
            },
            type       => 'Left',
            conditions => [
                {
                    left => {
                        name => 'country_id',
                        view => 'People'
                    },
                    right => {
                        name => 'id',
                        view => 'a_country'
                    },
                    operator        => '=',
                    open_parentheses  => 0,
                    close_parentheses => 0,
                }
            ]
        },
    ],
};

my $da = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );


my $dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_links( $in_hash, $da, $dad, 1 );

my $in_hash2 = {
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
        },
        {
            name => 'name',
            view => 'country'
        }
    ],

    links => {
        to => {
            name  => 'country_hash2_link',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left => {
                    name => 'country_id',
                    view => 'People'
                },
                right => {
                    name => 'id',
                    view => 'a_country'
                },
                # operator        => '=',
                # open_parentheses  => 1,
                close_parentheses => 0,
                # condition       => 'AND',
            }
        ]
    },
};

$da = Database::Accessor->new($in_hash2);
$return = {};
$da->retrieve( Data::Test->new(), $return );

$dad = $da->result->error(); #note to others this is a kludge for testing
use Data::Dumper;
# warn("da=".Dumper($da->links));
# warn("da=".Dumper($dad->links));

Test::Database::Accessor::Utils::deep_links( $in_hash2, $da, $dad, 1 );




1;
