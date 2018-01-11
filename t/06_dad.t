#!perl 
{
  package Test;
  use Moose;
 sub new {
    my $class = shift;

    my $self = {};
    bless( $self, ( ref($class) || $class ) );

    return( $self );
    
}
 sub DB_Class{
    return 1;  
  }
  sub Execute {
     return 1;   
  }
}

use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More;
use Moose::Util qw(apply_all_roles does_role with_traits);

use Database::Accessor;
use_ok("Database::Accessor");
use_ok("Database::Accessor::Roles::DAD");

my $test = Test->new();
my $accessor = Database::Accessor->new();

eval {
  apply_all_roles( $test, "Database::Accessor::Roles::DAD");
};

   if ($@) {
       
      fail("Can not apply role 'Database::Accessor::Roles::DAD'; errr=$@");
   }
   else {
       pass("Can apply role 'Database::Accessor::Roles::DAD");
   }

 foreach my $attribute ($accessor->meta->get_all_attributes){
    next
      if (index($attribute->name(),'_') eq 0);
    my $dad_attribute = ucfirst($attribute->name());
    ok($test->can($dad_attribute),"Role DAD can $dad_attribute")
   
 }

 done_testing()