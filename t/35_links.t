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
                             
        links=>[{to        =>{name=>'country',
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
                             
        links=>{to        =>{name=>'country',
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
  };
 
 

  my $da = Database::Accessor->new($in_hash);
   
  my $return_str = undef;
  my $data = Data::Test->new();

   my $dad = $da->retrieve($data,$return_str);
  
   my $da_links  = $da->links()->[0];
   my $dad_links = $dad->Links();
   my $in   = $in_hash->{links}->[0];
     warn("da=".Dumper($in));
    bless($in,"Database::Accessor::Link"); 
    bless($in->{to},"Database::Accessor::View"); 
    bless($in->{predicates}->[0],"Database::Accessor::Predicate"); 
    bless($in->{predicates}->[0]->{left},"Database::Accessor::Element"); 
     bless($in->{predicates}->[0]->{right},"Database::Accessor::Element"); 
  warn("da=".Dumper($in));
    warn("da=".Dumper($da_links));
  cmp_deeply($da_links, methods(%{$in}),"DA predicates correct" );
     # cmp_deeply($dad_conditions->[$index]->predicates->[0], methods(%{$in}),"DAD predicates no $index correct" );
  
   my $da = Database::Accessor->new($in_hash2);
 
 
 
 
   # foreach my $index (0..scalar(@{$in_conditions}-1)) {
     # my $in   = $in_conditions->[$index];
     
     # bless($in,"Database::Accessor::Predicate"); 
     # bless($in->{left},"Database::Accessor::Element"); 
     # bless($in->{right},"Database::Accessor::Param"); 
     
  
     # cmp_deeply($da_conditions->[$index]->predicates->[0], methods(%{$in}),"DA predicates correct" );
     # cmp_deeply($dad_conditions->[$index]->predicates->[0], methods(%{$in}),"DAD predicates no $index correct" );
      # # cmp_deeply( $dad_conditions->predicates->[$index], methods(%{$in}),"DAD predicates correct" );
   
   # }

  # my $in_hash3 = {
     # view     => {name => 'People'},
     # elements => [{name => 'first_name',
                   # view =>'People' },
                  # {name => 'last_name',
                   # view => 'People' },
                  # {name => 'user_id',
                   # view =>'People' } ],
    # conditions=>{left =>{name =>'last_name',
                         # view =>'People'},
                 # right=>{value=>'test'},
                 # operator       =>'=',
                 # open_parenthes =>1,
                 # close_parenthes=>0,
                 # condition      =>'AND',
                 # }
                     # ,
  # };
  # my $da2 = Database::Accessor->new($in_hash3);
  # ok(ref($da2->conditions()->[0]) eq "Database::Accessor::Condition",'DA has a condtion');
  # ok(scalar(@{$da2->conditions()}) == 1,'DA has only 1 condtion');
  # ok(scalar(@{$da2->conditions()->[0]->predicates}) == 1,'DA has only 1 predicate');
  # ok(ref($da2->conditions()->[0]->predicates->[0]) eq "Database::Accessor::Predicate",'DA has a condtion predicate is a predicate');
  
   