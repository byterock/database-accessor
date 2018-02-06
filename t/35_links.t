#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;
use Test::More tests => 6;

use Data::Test;

BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
    use_ok('Database::Accessor::Link');
}


   my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' },
                             { name=>'name',
                               view=>'country'} ],
                             
        links=>[{to        =>{name=>'Hash_1_link',
                              alias=>'a_country'},
                 type      =>'Left',
                 predicates =>[{left     =>{name =>'country_id',
                                            view =>'People'},
                                right    =>{name=>'id',
                                            view=>'a_country'},
                                operator       =>'=',
                                open_parenthes =>1,
                                close_parenthes=>0,
                                condition      =>'AND',
                             }]},
                ],
  };
 

 

   my $da = Database::Accessor->new($in_hash);
   
  
   my $return = {};
    $da->retrieve(Data::Test->new(),$return); 
   
    my $dad = $return->{dad};
    
   Test::Database::Accessor::Utils::deep_links($in_hash,$da,$dad,1);
 

   my $in_hash2 = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' },
                             { name=>'name',
                               view=>'country'} ],
                             
        links=>{ to         =>{name=>'country_hash2_link',
                               alias=>'a_country'},
                 type       =>'Left',
                 predicates =>[{left =>{name =>'country_id',
                                        view =>'People'},
                                right =>{name=>'id',
                                         view=>'a_country'},
                                operator       =>'=',
                                open_parenthes =>1,
                                close_parenthes=>0,
                                condition      =>'AND',
                             }]},
  };
 
   $da = Database::Accessor->new($in_hash2);
  my $return = {};
    $da->retrieve(Data::Test->new(),$return); 
   
    my $dad = $return->{dad};
   Test::Database::Accessor::Utils::deep_links($in_hash2,$da,$dad,1);

 
 