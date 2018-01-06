
#!perl 
{
  package DBI::db;
 sub new {
    my $class = shift;

    my $self = {};
    bless( $self, ( ref($class) || $class ) );

    return( $self );

}
 

}
{
  package MongoDB::Collection;
 sub new {
    my $class = shift;

    my $self = {};
    bless( $self, ( ref($class) || $class ) );

    return( $self );

}


}             

use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 13;
use Moose::Util qw(apply_all_roles does_role with_traits);
use Time::HiRes;

BEGIN {
    use_ok('Database::Accessor');
}


my $address = Database::Accessor->new(
    {
        view     => {name  => 'person',
                     alias => 'me'},
        elements => [{ name => 'street', },
                     { name => 'city', },
                     { name => 'country', } ],
        conditions=>[{name=>'country is not a city',
                      left=>{name=>'country'},
                     operator=>'!=',
                     right=>{name=>'city'}}]
    }
);

eval {
   $address->view($street);
  };
   if ($@) {
       
      pass("Can only take a View Class");
   }
   else {
       fail("Takes a non View Class");
   }

ok( ref($address->view()) eq 'Database::Accessor::View', "View is a Database::Accessor::View" );

foreach my $element (@{$address->elements()}){
    ok( ref($element) eq 'Database::Accessor::Element', "Element ".$element->name()." is a Database::Accessor::Element" );
    
}    

foreach my $predicate (@{$address->conditions()}){
    ok( ref($predicate) eq 'Database::Accessor::Predicate', "Condtion ".$predicate->name()." is a Database::Accessor::Predicate" );
    ok( ref($predicate->left()) eq 'Database::Accessor::Element', "Left ".$predicate->left()->name()." is a Database::Accessor::Element");
    ok( ref($predicate->right()) eq 'Database::Accessor::Element', "Right ".$predicate->right()->name()." is a Database::Accessor::Element");
    ok( $predicate->operator eq '!=',"Operator is !=")
}   

ok( ref($address) eq 'Database::Accessor', "Address is a Database::Accessor" );
my $fake_dbh = DBI::db->new();

warn( $address->retrieve( $fake_dbh, $result ) );

ok(
    $address->retrieve( $fake_dbh, $result ) eq
      'SELECT  street, city, country FROM person  AS me WHERE country != city ',
    'SQL correct'
);
my $fake_mongo = MongoDB::Collection->new();

ok(
    $address->retrieve($fake_mongo) eq
      'db.person.find({},{ street: 1, city: 1, country: 1}',
    "Mongo Query correct"
);


 done_testing()

