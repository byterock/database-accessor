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

use Test::More tests => 9;
use Test::Deep;

my $in_hash = {
    view     => { name => 'People' },
    elements => [
        {
            name => 'first_name',
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
            name => 'street',
            view => 'Address'
        }
    ],
};

my $da = Database::Accessor->new($in_hash);

my $container = {};
my $container_array = [];
my $data       = Data::Test->new();
eval {
 $da->create( undef, $container );
};

ok( $@, 'No Create with out connection class' );

eval {
 $da->create( $data, $container );
};

ok( $@, 'No Create with empty hash-ref container ' );

$container->{last_name}=1;
ok($da->create( $data, $container ),"Container can be a non empty Hash-ref");
ok($da->create( $data, $data ),"Container can be a Class");

eval {
 $da->create( $data, $container_array );
};

ok( $@, 'No Create with empty array-ref container ' );

push(@{$container_array},1);
push(@{$container_array},$container);
push(@{$container_array},$data);
eval {
 $da->create( $data, $container_array );
};

ok( $@, 'No Create with array-ref container that has a scalar' );

shift(@{$container_array});
ok($da->create( $data, $container_array ),"Container can be an Array-ref of Hash-ref and Classed");

$container = {first_name=>'Bob',
              street    =>'1313 Mocking bird lane',
              };

 $da->create( $data, $container );;

 my $in_container =   $da->result->in_container();
 
  cmp_deeply(
            $in_container,
            {first_name=>'Bob'},
            "Container drops street on create"
        );
        
$container = {first_name=>'Bob',
              last_name=>'Barker',
              street    =>'1313 Mocking bird lane',
              phone     =>'555mrplow'};

 $da->create( $data, $container );;

$in_container =   $da->result->in_container();

  cmp_deeply(
            $in_container,
            {first_name=>'Bob',
             last_name=>'Barker'},
            "Container drops street and phone on create"
        );