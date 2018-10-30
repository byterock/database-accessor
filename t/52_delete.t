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
use Database::Accessor::Constants;

use Test::More tests =>9;


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
 $da->delete( undef, $return_str );
};

ok( $@, 'No delete with out connection class' );



my $data       = Data::Test->new();
eval { $da->delete( $data, $return_str ); };
ok( $@, 'Cannot delete without condition' );
ok( index( $@, 'Attempt to delete without condition' ) != 1,
    'Error message OK' );

$in_hash->{delete_requires_condition} = 0;
$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( !$@, 'Can delete when delete_requires_condition is off' );

delete( $in_hash->{delete_requires_condition} );

my $conditions = [
    {
        left => {
            name => 'first_name',
            view => 'People'
        },
        right           => { value => 'test' },
        operator        => '=',
        condition       => 'AND',
    }
];
$da = Database::Accessor->new($in_hash);

$in_hash->{conditions} = $conditions;
$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( !$@, "$@ Can delete with only static condition" );

delete( $in_hash->{conditions} );

$da = Database::Accessor->new($in_hash);
$da->add_condition( $conditions->[0] );

eval { $da->delete( $data, $return_str ); };
ok( !$@, 'Can delete with only dynamic condition' );

$da = Database::Accessor->new($in_hash);
$da->add_condition( $conditions->[0] );
$in_hash->{conditions} = $conditions;

eval { $da->delete( $data, $return_str ); };
ok( !$@, 'Can delete with static and dynamic conditions' );


$in_hash->{no_delete} = 1;

$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( $@, 'No Delete with no_delete flag' );

# warn($@);

delete( $in_hash->{no_delete} );
$in_hash->{retrieve_only} = 1;

$da = Database::Accessor->new($in_hash);

eval { $da->delete( $data, $return_str ); };
ok( $@, 'No Delete with retrieve_only flag' );

# warn($@);
