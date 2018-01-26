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
  
  
   my $da_sorts  = $da->sorts();
   my $dad_sorts = $dad->Sorts();
   my $in         = $in_hash->{sorts};
   my $in_dad      = $in_hash->{sorts};
   foreach my $index (0..2){
      bless($in->[$index],"Database::Accessor::Element");
      cmp_deeply($da_sorts->[$index], methods(%{$in->[$index]}),"DA sort $index correct" );
      cmp_deeply($dad_sorts->[$index], methods(%{$in->[$index]}),"DAD sort $index correct" );
   }
  
