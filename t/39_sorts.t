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
    use_ok('Database::Accessor::Link');
}


  
    
     my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        sorts => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
  };
 

    my $da = Database::Accessor->new($in_hash);
   
  my $return_str = undef;
  my $data = Data::Test->new();

   my $dad = $da->retrieve($data,$return_str);
  
   Test::Database::Accessor::Utils::deep_element($in_hash->{sorts},$da->sorts,$dad->Sorts,'Sorts');

$in_hash = {
        sorts => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
  };
  
    $da = Database::Accessor->new({view     => {name  => 'People'}});
     
   foreach my $sort (@{$in_hash->{sorts}}){
      ok($da->add_sort($sort),"can add an single Dynamic sort");
   }
   
   $dad = $da->retrieve($data,$return_str);
   Test::Database::Accessor::Utils::deep_element($in_hash->{sorts},$da->dynamic_sorts,$dad->sorts,'dynamic sorts');
   
   
   ok($da->add_sort(@{$in_hash->{sort}}),"can add an Array of Dynamic sorts");
   
      $dad = $da->retrieve($data,$return_str);
   Test::Database::Accessor::Utils::deep_element($in_hash->{sorts},$da->dynamic_sorts,$dad->sorts,'Array of dynamic sorts');
   
     ok($da->add_sort($in_hash->{sort}),"can add an Array Ref of Dynamic sorts");
   
      $dad = $da->retrieve($data,$return_str);
   Test::Database::Accessor::Utils::deep_element($in_hash->{sorts},$da->dynamic_sorts,$dad->sorts,'Array Ref of dynamic sorts');