#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;
use Database::Accessor::Constants;

use Test::More tests => 1;

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
my $data       = Data::Test->new();

my $dad = $da->create( $data, $return_str );

ok( $return_str->{type} eq Database::Accessor::Constants::CREATE )
