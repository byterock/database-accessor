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


  
    
   my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        gathers => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        filters=>[{left           =>{name =>'last_name',
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
  Test::Database::Accessor::Utils::deep_element($in_hash->{gathers},$da->gathers,$dad->Gathers,'Gather');
  Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->filters(),$dad->Filters(),'Filters');
   
   
  
   
 