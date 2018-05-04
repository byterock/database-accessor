
#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use MooseX::Test::Role;
use Test::More tests => 68;


my $da =
  Database::Accessor->new( { retrieve_only => 1, view => { name => 'test' } } );

my $view = $da->view();

my $dad_role = consuming_class("Database::Accessor::Roles::Driver");

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
        ok( !$attr->get_write_method ,
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

my $da_new = Database::Accessor->new( { delete_requires_condition=>0,
                                        update_requires_condition=>0,
                                        view => { name => 'test' } } );

ok( $da_new->no_create() == 0,   "Can Create" );
ok( $da_new->no_retrieve() == 0, "Can Retrieve" );
ok( $da_new->no_update() == 0,   "Can Update" );
ok( $da_new->no_delete() == 0,   "Can Delete" );

ok( ref($da_new) eq 'Database::Accessor', "DA is a Database::Accessor" );

foreach my $type (qw(create retrieve update delete)){
    my $container = {key=>1};
     ok($da_new->$type(Data::Test->new(),$container),"$type Query ran");
     if ($type eq 'create') {
       ok($da_new->result()->is_error == 0,"$type->No Error");
       ok($da_new->result()->effected() == 10,"$type->10 rows effected");
       ok($da_new->result()->query() eq uc($type).' Query','correct '.uc($type)." query returned");
       ok($da_new->result()->DAD() eq 'Database::Accessor::Driver::Test',"$type->correct raw DAD class");
       ok($da_new->result()->DB() eq 'Data::Test',"$type->correct DB");
       ok(ref($da_new->result()->error) eq 'Database::Accessor::Driver::Test', "Got an object in the error class")
     }
}