#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 40;



my $da = Database::Accessor->new( { view => { name => 'People' } } );

my $in_hash = {
    links => [
        {
            to => {
                name  => 'country',
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
                    open_parentheses  => 1,
                    close_parentheses => 0,
                }
            ]
        },
        {
            to => {
                name  => 'country',
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
                    close_parentheses => 1,
                }
            ]
        }
    ],
};

foreach my $link ( @{ $in_hash->{links} } ) {

    ok( $da->add_link($link), "can add an single Dynamic link" );
}

my $return = {};
$da->retrieve( Data::Test->new(), $return );

my $dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_links( $in_hash, $da, $dad, 0 );

ok(
    $da->add_link( @{ $in_hash->{links} } ),
    "can add an array of Dynamic links"
);

$return = {};
$da->retrieve( Data::Test->new(), $return );

$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_links( $in_hash, $da, $dad, 0 );

$da = Database::Accessor->new( { view => { name => 'People' } } );

ok(
    $da->add_link( $in_hash->{links} ),
    "can add an Array REF of Dynamic links"
);

$return = {};
$da->retrieve( Data::Test->new(), $return );

$dad = $da->result->error(); #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_links( $in_hash, $da, $dad, 0 );
1;
