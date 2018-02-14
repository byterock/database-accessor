#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use Data::Dumper;
use Data::Test;
use Test::Database::Accessor::Utils;
use Test::Deep;
use Test::More tests => 3;

BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}

  my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                       view => 'People',
                       alias=> 'user' },
                     { name => 'last_name',
                       view => 'People',
                       alias=> 'user'  },
                     { name => 'user_id',
                       view =>'People',
                       alias=> 'user'  },
                        ],
    };

   my $da = Database::Accessor->new($in_hash);
   my $return = {};
    $da->retrieve(Data::Test->new(),$return); 
    my $dad = $return->{dad};
   
   foreach my $element (@{$in_hash->{elements}}){
      ok($da->add_element($element),"can add an single Dynamic element");
   }

   $da->retrieve(Data::Test->new(),{});
   
   Test::Database::Accessor::Utils::deep_element($in_hash->{elements},$da->dynamic_elements,$dad->elements,'Single Dynamic Element');
   
   ok($da->add_element(@{$in_hash->{elements}}),"can add an array of Dynamic elements");
  
 $da->retrieve(Data::Test->new(),{});
    $da->retrieve(Data::Test->new(),$return); 
      $dad = $return->{dad};
   Test::Database::Accessor::Utils::deep_element($in_hash->{elements},$da->dynamic_elements,$dad->elements,'Array Dynamic Element');
   
    ok($da->add_element($in_hash->{elements}),"can add an ref array of Dynamic elements");
  
  $da->retrieve(Data::Test->new(),$return); 
    my $dad = $return->{dad};
   
   Test::Database::Accessor::Utils::deep_element($in_hash->{elements},$da->dynamic_elements,$dad->elements,'Array Dynamic Element');
   
   