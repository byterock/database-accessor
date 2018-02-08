#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use strict;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 2;
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;
use Data::Test;
use Database::Accessor::Constants;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";

}

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
eval { $da->delete( $data, $return_str ); };
ok( $@, 'Cannot delete without condition' );
$in_hash->{delete_requires_condtion} = 0;
$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( !$@, 'Can delete when delete_requires_condtion is off' );

delete( $in_hash->{delete_requires_condtion} );

my $conditions = [
    {
        left => {
            name => 'First_1',
            view => 'People'
        },
        right           => { value => 'test' },
        operator        => '=',
        open_parenthes  => 1,
        close_parenthes => 0,
        condition       => 'AND',
    }];
    $da = Database::Accessor->new($in_hash);
    
 $in_hash->{conditions} = $conditions;   
$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( !$@, 'Can delete with only static condtion' );

delete( $in_hash->{conditions} );


$da = Database::Accessor->new($in_hash); $da->add_condition( $conditions->[0] );

eval { $da->delete( $data, $return_str );};
  ok( !$@, 'Can delete with only dynamic condtion' );  
  
  $da = Database::Accessor->new($in_hash);
 $da->add_condition( $conditions->[0] );$in_hash->{conditions} = $conditions;  

eval { $da->delete( $data, $return_str );
};
  ok( !$@, 'Can delete with static and dynamic condtions' );  