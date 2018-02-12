#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use Data::Dumper;
use Test::More tests => 3;
use Data::Test;
BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}
use Test::Deep;



my $in_hash = {
        view => {name=>'name',
                 alias=>'alias'},
  
    };

   my $da = Database::Accessor->new($in_hash);
   my $return = {};
   $da->retrieve(Data::Test->new(),$return); 
   my $dad = $return->{dad};
    bless($in_hash->{view},"Database::Accessor::View"); 
   
    cmp_deeply($da->view, methods(%{$in_hash->{view}}),"DA View is correct" );
    cmp_deeply($dad->view, methods(%{$in_hash->{view}}),"DAS View is correct" );
   
   eval {
     my $test = $da->{view}
   };
   if ($@){
       pass("Cannot access attribute directly");
    }
    else {
      fail("Cannot access attribute directly");     
    }
   
   eval {
      $da->{view} ='somethig';
   };
   if ($@){
       pass("Cannot change attribute directly");
    }
    else {
      fail("Cannot change attribute directly");     
    }
   
    eval {
      $da = Database::Accessor->new({});
    };
    if ($@){
       pass("View is Required");
       ok(ref($@) eq 'MooseX::Constructor::AllErrors::Error::Constructor','Got error Constructor object');
    }
    else {
      fail("View is Required");     
    }
    
     $in_hash = {
        view => {name=>undef,
                 alias=>undef}
                 };
    eval {
      $da = Database::Accessor->new($in_hash);
    };
    ok($@->has_errors(),"Error on New");
    ok(scalar($@->errors) == 2,"Two errors on new");
    my @errors = $@->errors;
    ok($errors[0]->attribute->name() == 'name',"View: param name fails");
    ok($errors[1]->attribute->name() == 'alias',"View: param alias fails");
    
  

