#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 11;
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;

use Data::Test;
BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
   
}


  my $da = Database::Accessor->new({view     => {name  => 'People'}});
  
  my $in_hash = {
           gathers => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
       
                                    
                     
  };
  
   foreach my $gather (@{$in_hash->{gathers}}){
      ok($da->add_gather($gather),"can add an single Dynamic gather");
   }
    my $return = {};
    $da->retrieve(Data::Test->new(),$return); 
   
    my $dad = $return->{dad};
 
    Test::Database::Accessor::Utils::deep_element($in_hash->{gathers},$da->dynamic_gathers,$dad->dynamic_gathers,'Dynamic Gather');
 
    $da = Database::Accessor->new({view     => {name  => 'People'}});
    
    
    ok($da->add_gather($in_hash->{gathers}),"can add an array of Dynamic gathers");
     
   $in_hash = {filters=>[{left           =>{name =>'last_name',
                                                      view =>'People'},
                                    right          =>{value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>1,
                                    close_parenthes=>0,
                                    condition      =>'AND',
                                   },
                                   {condition      =>'AND',
                                    left           =>{name=>'first_name',
                                                      view=>'People'},
                                    right          =>{ value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>0,
                                    close_parenthes=>1
                                    }
                                    ]
   };
   
     $da = Database::Accessor->new({view     => {name  => 'People'}});
     
   foreach my $filter (@{$in_hash->{filters}}){
      ok($da->add_filter($filter),"can add an single Dynamic filter");
   }
 
       $da->retrieve(Data::Test->new(),$return); 
    $dad = $return->{dad};

    Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->dynamic_filters(),'dynamic filters');
  
    $da = Database::Accessor->new({view     => {name  => 'People'}});
   
    ok($da->add_filter($in_hash->{filters}),"can add an array ref of Dynamic filters");
  
       $da->retrieve(Data::Test->new(),$return); 
    $dad = $return->{dad};
 
   Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->dynamic_filters(),'array ref of dynamic filters');
   
    $da = Database::Accessor->new({view     => {name  => 'People'}});
   
    ok($da->add_filter(@{$in_hash->{filters}}),"can add an array of Dynamic filters");
  
      $da->retrieve(Data::Test->new(),$return); 
    $dad = $return->{dad};
 
   Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->dynamic_filters(),'Array of dynamic filters');
   1;
