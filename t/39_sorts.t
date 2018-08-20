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

my $in_hash = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
    view                      => { name => 'People' },
    elements                  => [
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
my $dad = $da->result->error();    #note to others this is a kludge for testing

Test::Database::Accessor::Utils::deep_element( $in_hash->{sorts}, $da->sorts,
    $dad->sorts, 'Sorts' );

$in_hash->{sorts} = undef;

eval { $da = Database::Accessor->new( $in_hash ); };
if ($@) {
    pass("sorts cannot be undef");
    ok( ref($@) eq 'MooseX::Constructor::AllErrors::Error::Constructor',
        'Got error Constructor object' );
}
else {
    fail("View is Required");
}

foreach my $type (qw(create update delete)) {
    $da->$type( Data::Test->new(), { test => 1 } );
    $dad = $da->result->error();    #note to others this is a kludge for testing
    ok( $dad->sort_count == 3, "correct Sort count on $type" );
}

$in_hash->{sorts} = [{
    whens => [
        {
            left      => { name  => 'Price', },
            right     => { value => '10' },
            operator  => '<',
            statement => { name  => 'price' }
        },
        { statement => { name => 'prices' } }
      ]
  }];
  
  $da = Database::Accessor->new($in_hash);
  ok( ref( $da->sorts()->[0] ) eq "Database::Accessor::Case",
    'sort->[0]->right is a Case' );
1;
