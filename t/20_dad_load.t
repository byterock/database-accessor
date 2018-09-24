
#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use MooseX::Test::Role;
use Test::More tests => 67;
use Test::Fatal;
use Test::Deep;

my $da =
  Database::Accessor->new( { retrieve_only => 1, view => { name => 'person' }, elements=>[{ name => 'street', view => 'person', }] } );


my %read_write = (da_compose_only=>1,
                  da_no_effect=>1,
                  da_raise_error_off=>1,
                  da_warning=>1,
                  da_suppress_view_name=>1);
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
        if (exists($read_write{$attribute->name()})){
        
          ok( $attr->get_write_method ,
            "Role DAD attribute: $dad_attribute is Read Write" );
        }
        else {
           ok( !$attr->get_write_method ,
            "Role DAD attribute: $dad_attribute is Read Only" ); 
        }
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
                                        view => { name => 'person' },
                                        elements=>[{ name => 'street', view => 'person', }] } );

ok( $da_new->no_create() == 0,   "Can Create" );
ok( $da_new->no_retrieve() == 0, "Can Retrieve" );
ok( $da_new->no_update() == 0,   "Can Update" );
ok( $da_new->no_delete() == 0,   "Can Delete" );

ok( ref($da_new) eq 'Database::Accessor', "DA is a Database::Accessor" );

foreach my $type (qw(create retrieve update )){
     my $container = {key=>1,
                     street=>'131 Madison Ave.' };
     my $in_container = {street=>'131 Madison Ave.',
                        };
     my $processed_container = {street     =>'131 Madison Ave.',
                                dad_fiddle =>1};
     ok($da_new->$type(Data::Test->new(),$container) == 1,"$type Query ran");
     if ($type eq 'create' or $type eq 'update') {
       ok($da_new->result()->is_error == 0,"$type->No Error");
       ok($da_new->result()->effected() == 10,"$type->10 rows effected");
       ok($da_new->result()->query() eq uc($type).' Query','correct '.uc($type)." query returned");
       ok($da_new->result()->DAD() eq 'Database::Accessor::Driver::Test',"$type->correct raw DAD class");
       ok($da_new->result()->DB() eq 'Data::Test',"$type->correct DB");
       ok(ref($da_new->result()->error) eq 'Database::Accessor::Driver::Test', "Got an object in the error class");
       warn("da result=".Dumper($da_new->result()->processed_container()));
       cmp_deeply(
            $container,
            {key=>1, street=>'131 Madison Ave.' },
            "Container stays the same!"
        );        cmp_deeply(
            $in_container,
            $da_new->result()->in_container(),
            "In Container stays the same!"
        );
        cmp_deeply(
            $processed_container,
            $da_new->result()->processed_container(),
            "Processed Container drops key!"
        );
     }
}





like(
    exception {my $da = Database::Accessor->new( {view => { name => 'person' }} ) },
    qr /Attribute \(elements\) is required at/,
    "Elements is a required Field "
);

like(
    exception { Database::Accessor->new( {elements=>[{ name => 'street', view => 'person', }]} ) },
    qr /Attribute \(view\) is required at /,
    "View is a required Field"
);
like(
    exception {my $da = Database::Accessor->new( {view => { name => 'person' },elements=>[]} ) },
    qr /ArrayRefofElements can not be an empty array ref/,
    "Elements cannot be empty array ref"
);
# $da = Database::Accessor->new();