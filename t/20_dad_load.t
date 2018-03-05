#!perl
use Test::More 0.82;

use lib ('..\t\lib');
use strict;
use MooseX::Test::Role;
use Test::More tests => 47;
use Data::Dumper;
use lib 'D:\GitHub\database-accessor\lib';
use Database::Accessor;
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Roles::DAD');
    use_ok('Data::Test');
}


my $da =
  Database::Accessor->new( { retrieve_only => 1, view => { name => 'test' } } );

my $view = $da->view();

my $dad_role = consuming_class("Database::Accessor::Roles::DAD");

foreach my $attribute ( $da->meta->get_all_attributes ) {
    next
      if ( index( $attribute->name(), '_' ) eq 0 );
    my $dad_attribute = $attribute->name();
    
   next
     if (  $attribute->can('description')
     and $attribute->description->{not_in_DAD} );
     
    if ( $dad_role->can($dad_attribute) ) {
        pass("Role DAD can $dad_attribute");
        my $attr = $dad_role->meta->get_attribute($dad_attribute);
        if ( $attribute->type_constraint() eq $attr->type_constraint() ) {
            pass( "Role DAD attribute: $dad_attribute had correct type of "
                  . $attribute->type_constraint() );
        }
        else {
            fail(   "Role DAD attribute: $dad_attribute had in correct type of "
                  . $attr->type_constraint()
                  . ". Should be a "
                  . $attribute->type_constraint() );
        }
        ok( $attr->get_write_method eq undef,
            "Role DAD attribute: $dad_attribute is Read Only" );
    }
    else {
        fail("Role DAD can $dad_attribute");
    }

}

ok( $da->no_create() == 1,   "Cannot Create" );
ok( $da->no_retrieve() == 0, "Can Retrieve" );
ok( $da->no_update() == 1,   "Cannot Update" );
ok( $da->no_delete() == 1,   "Cannot Delete" );

ok( ref($da) eq 'Database::Accessor', "DA is a Database::Accessor" );
