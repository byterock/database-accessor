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
   
  my $return_str = undef;
  my $data = Data::Test->new();

   my $dad = $da->retrieve($data,$return_str);
  
  
   my $da_gathers  = $da->gathers();
   my $dad_gathers = $dad->Gathers();
   my $in         = $in_hash->{gathers};
   my $in_dad      = $in_hash->{gathers};
   foreach my $index (0..2){
      bless($in->[$index],"Database::Accessor::Element");
      cmp_deeply($da_gathers->[$index], methods(%{$in->[$index]}),"DA gather $index correct" );
      cmp_deeply($dad_gathers->[$index], methods(%{$in->[$index]}),"DAD gather $index correct" );
   }
  
   my $da_filters  = $da->filters();
   my $dad_filters = $dad->Filters();
   my $in_filters  = $in_hash->{filters};
 
   foreach my $index (0..scalar(@{$in_filters}-1)) {
     my $in   = $in_filters->[$index];
     
     bless($in,"Database::Accessor::Predicate"); 
     bless($in->{left},"'Database::Accessor::Element"); 
     bless($in->{right},"Database::Accessor::Param"); 
     
  
     cmp_deeply($da_filters->[$index]->predicates->[0], methods(%{$in}),"DA filters predicates $index correct" );
     cmp_deeply($dad_filters->[$index]->predicates->[0], methods(%{$in}),"DAD filters predicates $index correct" );
      # cmp_deeply( $dad_conditions->predicates->[$index], methods(%{$in}),"DAD predicates correct" );
   
   }
   
   my $dad_links = $dad->Links();
   my $in   = $in_hash->{links}->[0];
     
  
 
 