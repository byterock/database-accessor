
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
use Test::More tests => 11;
use Moose::Util qw(apply_all_roles does_role with_traits);
use Time::HiRes;

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::View');
    use_ok('Database::Accessor::Element');
}

my $view = Database::Accessor::View->new({name  => 'person',alias => 'me'});
ok( ref($view) eq 'Database::Accessor::View', "Person is a View" );
my $street = Database::Accessor::Element->new( { name => 'street', } );
ok( ref($street) eq 'Database::Accessor::Element', "Street is an Element" );
my $country = Database::Accessor::Element->new( { name => 'country', } );
ok( ref($country) eq 'Database::Accessor::Element', "County is an Element" );
my $city = Database::Accessor::Element->new( { name => 'city', } );
ok( ref($city) eq 'Database::Accessor::Element', "City is an Element" );
my @elements = ( $street, $city, $country );


my $address = Database::Accessor->new(
    {
        view     => $view,
        elements => \@elements
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
 ok( ref($address) eq 'Database::Accessor', "Address is a Database::Accessor" );
 my $fake_dbh = DBI::db->new();
ok(
    $address->retrieve( $fake_dbh, $result ) eq
      'SELECT  street, city, country FROM person  AS me',
    'SQL correct'
);
my $fake_mongo = MongoDB::Collection->new();

ok(
    $address->retrieve($fake_mongo) eq
      'db.person.find({},{ street: 1, city: 1, country: 1}',
    "Mongo Query correct"
);




