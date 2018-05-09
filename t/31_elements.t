#!perl
use strict;
use warnings;

use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 7;


my $in_hash = {
    view     => { name => 'People' },
    elements => [
        {
            name  => 'first_name',
            #view  => 'People',
            alias => 'user'
        },
        {
            name  => 'last_name',
            view  => 'People',
            alias => 'user'
        },
        {
            name  => 'user_id',
            view  => 'People',
            alias => 'user'
        },
    ],
};

my $da     = Database::Accessor->new($in_hash);

ok($da->elements->[0]->view eq 'People', "View taked from DA view name");

my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing
Test::Database::Accessor::Utils::deep_element( $in_hash->{elements},
    $da->elements, $dad->elements, 'Element' );
1;
