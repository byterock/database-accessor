#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 6;
use lib ('..\t\lib');

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
        conditions=>[{predicates=>[{left           =>{name =>'last_name',
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
                                    }
                     ],
  };
   my $in_hash2 = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        conditions=>[{left           =>{name =>'last_name',
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
                                    
                     ,
  };
 
  my $da = Database::Accessor->new($in_hash2);
   
  my $return_str = undef;
  my $data = Data::Test->new();

  my $dad = $da->retrieve($data,$return_str);
  
 
  ok(ref($dad) eq "Database::Accessor::DAD::Test",'Got the Test DAD');
  
 
   my $da_conditions  = $da->conditions();
   my $dad_conditions = $dad->Conditions();
   my $in_conditions  = $in_hash2->{conditions};
 
   foreach my $index (0..scalar(@{$in_conditions}-1)) {
     my $in   = $in_conditions->[$index];
     
     bless($in,"Database::Accessor::Predicate"); 
     bless($in->{left},"'Database::Accessor::Element"); 
     bless($in->{right},"Database::Accessor::Param"); 
     
  
     cmp_deeply($da_conditions->[$index]->predicates->[0], methods(%{$in}),"DA predicates correct" );
     cmp_deeply($dad_conditions->[$index]->predicates->[0], methods(%{$in}),"DAD predicates no $index correct" );
      # cmp_deeply( $dad_conditions->predicates->[$index], methods(%{$in}),"DAD predicates correct" );
   
   }

  my $in_hash3 = {
     view     => {name => 'People'},
     elements => [{name => 'first_name',
                   view =>'People' },
                  {name => 'last_name',
                   view => 'People' },
                  {name => 'user_id',
                   view =>'People' } ],
    conditions=>{left =>{name =>'last_name',
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
  
   