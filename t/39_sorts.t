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
