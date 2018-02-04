#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 6;
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;

use Data::Test;
BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}


 
  my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        conditions=>[{left           =>{name =>'First_1',
                                                      view =>'People'},
                                    right          =>{value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>1,
                                    close_parenthes=>0,
                                    condition      =>'AND',
                                   },
                                   {condition      =>'AND',
                                    left           =>{name=>'First_2',
                                                      view=>'People'},
                                    right          =>{ value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>0,
                                    close_parenthes=>1
                                    }
                                    ]
                                    
                     ,
  };
  my $da = Database::Accessor->new($in_hash);
  my $dad = $da->retrieve(Data::Test->new());
  Test::Database::Accessor::Utils::deep_predicate($in_hash->{conditions},$da->conditions(),$dad->Conditions(),'conditions');
  
 
  my $in_hash3 = {
     view     => {name => 'People'},
     elements => [{name => 'first_name',
                   view =>'People' },
                  {name => 'last_name',
                   view => 'People' },
                  {name => 'user_id',
                   view =>'People' } ],
    conditions=>{left =>{name =>'second_1',
                         view =>'People'},
                 right=>{value=>'test'},
                 operator       =>'=',
                 open_parenthes =>1,
                 close_parenthes=>0,
                 condition      =>'AND',
                 }
                     ,
  };
  my $da2 = Database::Accessor->new($in_hash3);
  
  ok(ref($da2->conditions()->[0]) eq "Database::Accessor::Condition",'DA has a condtion');
  ok(scalar(@{$da2->conditions()}) == 1,'DA has only 1 condtion');
  ok(scalar(@{$da2->conditions()->[0]->predicates}) == 1,'DA has only 1 predicate');
  ok(ref($da2->conditions()->[0]->predicates->[0]) eq "Database::Accessor::Predicate",'DA has a condtion predicate is a predicate');
  

    $da = Database::Accessor->new({view     => {name  => 'People'}});
  
    $in_hash = {
        conditions=>[{left           =>{name =>'last_name2',
                                                      view =>'People'},
                                    right          =>{value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>1,
                                    close_parenthes=>0,
                                    condition      =>'AND',
                                   },
                                   {condition      =>'AND',
                                    left           =>{name=>'first_name3',
                                                      view=>'People'},
                                    right          =>{ value=>'test'},
                                    operator       =>'=',
                                    open_parenthes =>0,
                                    close_parenthes=>1
                                    }
                                    ]
                                    
                     ,
  };
  
  foreach my $condition (@{$in_hash->{conditions}}){
      ok($da->add_condition($condition),"can add an single Dynamic condition");
     
   }
   $dad = $da->retrieve(Data::Test->new(),{});
   
   Test::Database::Accessor::Utils::deep_predicate($in_hash->{conditions},$da->dynamic_conditions(),$dad->conditions(),'dynamic conditions');

     $dad = $da->retrieve(Data::Test->new(),{});

   
   ok($da->add_condition(@{$in_hash->{conditions}}),"can add an array of Dynamic conditions");
  
   
    Test::Database::Accessor::Utils::deep_predicate($in_hash->{conditions},$da->dynamic_conditions,$dad->conditions,'Array Dynamic condition');
   
      $dad = $da->retrieve(Data::Test->new(),{});

   
   ok($da->add_condition($in_hash->{conditions}),"can add an array Ref of Dynamic conditions");
  
   
    Test::Database::Accessor::Utils::deep_predicate($in_hash->{conditions},$da->dynamic_conditions,$dad->conditions,'Array Ref Dynamic condition');
   
    