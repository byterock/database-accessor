#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;
use Database::Accessor::Constants;

use Test::More tests => 7;

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
my $container_array = [];
my $data       = Data::Test->new();

eval {
 $da->create( undef, $return_str );
};

ok( $@, 'No Create with out connection class' );

eval {
 $da->create( $data, $return_str );
};

ok( $@, 'No Create with empty hash-ref container ' );

$return_str->{key}=1;

ok($da->create( $data, $return_str ),"Container can be a non empty Hash-ref");
ok($da->create( $data, $data ),"Container can be a Class");

eval {
 $da->create( $data, $container_array );
};

ok( $@, 'No Create with empty array-ref container ' );

push(@{$container_array},1);
push(@{$container_array},$return_str);
push(@{$container_array},$data);
eval {
 $da->create( $data, $container_array );
};

ok( $@, 'No Create with array-ref container that has a scalar' );

shift(@{$container_array});
ok($da->create( $data, $container_array ),"Container can be an Array-ref of Hash-ref and Classed");

my $driver = $da->result()->error(); #klugde for testing
warn("JSP=".scalar($driver->gathers()->count));
ok(scalar(@{$driver->gathers()}) == 0,'No gathers');