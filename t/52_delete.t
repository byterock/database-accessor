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
ok( $@,'Cannot delete without condition' );
ok(index($@,'Attempt to delete without condition')!=1,'Error message OK');

$in_hash->{delete_requires_condition} = 0;
$da = Database::Accessor->new($in_hash);
eval { $da->delete( $data, $return_str ); };

ok( !$@, 'Can delete when delete_requires_condition is off' );

delete( $in_hash->{delete_requires_condition} );

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


ok( !$@, 'Can delete with only static condition' );




$da = Database::Accessor->new($in_hash);

eval { 
    $da->delete( $data, $return_str );
  ok( !$@, 'Can delete with only dynamic condition' );
  

  $da = Database::Accessor->new($in_hash);
 $da->add_condition( $conditions->[0] );


};
  ok( !$@, 'Can delete with static and dynamic conditions' );  
  
ok($return_str->{type} eq Database::Accessor::Constants::DELETE,'Delete constant passed in and out');

  $in_hash->{no_delete} = 1;

$da = Database::Accessor->new($in_hash);
eval {  
};

ok ($@,'No Delete with no_delete flag'); 
 

  
   delete($in_hash->{no_delete});
   $in_hash->{retrieve_only} = 1;
  
   $da = Database::Accessor->new($in_hash);
  
 eval {  
  $da->delete( $data, $return_str );
 };
   ok ($@,'No Delete with retrieve_only flag');
  
# warn($@);
