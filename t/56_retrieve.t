#!perl
use strict;
# use warnings;
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
use Database::Accessor::Constants;

use Test::More tests => 2;


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
};


my $da = Database::Accessor->new($in_hash);
my $return_str = {};

eval {
 $da->retrieve( undef, $return_str );
};

ok( $@, 'No retrieve with out connection class' );


my $data       = Data::Test->new();
$da->retrieve( $data, $return_str );


eval { my $thig = $da->{elements}->[0]->{name};  };

ok( $@, 'Can not directly access attributes directly' );
