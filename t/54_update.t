#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;
use Database::Accessor::Constants;

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
};
my $conditions = [
    {
        left => {
            name => 'First_1',
            view => 'People'
        },
        right           => { value => 'test' },
        operator        => '=',
#        open_parentheses  => 1,
#        close_parentheses => 0,
        condition       => 'AND',
    }
];
my $da = Database::Accessor->new($in_hash);

my $return_str = {key=>1};
my $data       = Data::Test->new();


eval {
 $da->update( undef, $return_str );
};

ok( $@, 'No update with out connection class' );


eval { $da->update( $data, $return_str ); };
ok( $@, 'Cannot update without condition' );
$in_hash->{update_requires_condition} = 0;
$da = Database::Accessor->new($in_hash);
eval { $da->update( $data, $return_str ); };

ok( !$@, 'Can update when update_requires_condition is off' );

delete( $in_hash->{update_requires_condition} );

$da = Database::Accessor->new($in_hash);

$in_hash->{conditions} = $conditions;
$da = Database::Accessor->new($in_hash);

eval { $da->update( $data, $return_str ); };

ok( !$@, 'Can update with only static condition' );

delete( $in_hash->{conditions} );

$da = Database::Accessor->new($in_hash);
$da->add_condition( $conditions->[0] );

eval { $da->update( $data, $return_str ); };
ok( !$@, 'Can update with only dynamic condition' );

$da = Database::Accessor->new($in_hash);
$da->add_condition( $conditions->[0] );
$in_hash->{conditions} = $conditions;

eval { $da->update( $data, $return_str ); };
ok( !$@, 'Can update with static and dynamic conditions' );


ok($da->create( $data, $data ),"Update container can be a Class");

$return_str = {};
eval {
 $da->update( $data, $return_str );
};

ok( $@, 'No Update with empty hash-ref container ' );

