#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 8;

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
    sorts => [
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
};

my $da         = Database::Accessor->new($in_hash);
my $return_str = {};
my $data       = Data::Test->new();

$da->retrieve( Data::Test->new(), $return_str );
my $dad = $da->result->error(); #note to others this is a kludge for testing


Test::Database::Accessor::Utils::deep_element( $in_hash->{sorts}, $da->sorts,
    $dad->sorts, 'Sorts' );

$in_hash = {
    view  => { name => 'People' },
    sorts => undef
};
eval { $da = Database::Accessor->new( {} ); };
if ($@) {
    pass("sorts cannot be undef");
    ok( ref($@) eq 'MooseX::Constructor::AllErrors::Error::Constructor',
        'Got error Constructor object' );
}
else {
    fail("View is Required");
}
1;
