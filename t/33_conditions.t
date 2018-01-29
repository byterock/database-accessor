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
  
   