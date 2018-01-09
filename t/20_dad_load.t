#!perl 
use Test::More 0.82;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use strict;
use MooseX::Test::Role;
use Test::More tests => 14;
use Data::Dumper;
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Roles::DAD');
    use_ok('Data::Test');
}

my $da = Database::Accessor->new();
my $dad_role = consuming_class("Database::Accessor::Roles::DAD",{});

foreach my $attribute ($da->meta->get_all_attributes){
    next
      if (index($attribute->name(),'_') eq 0);
    my $dad_attribute = ucfirst($attribute->name());
    if ($dad_role->can($dad_attribute)){
        pass("Role DAD can $dad_attribute");
        my $attr = $dad_role->meta->get_attribute($dad_attribute);
        if ($attribute->type_constraint() eq $attr->type_constraint()){
           ok("Role DAD attribute: $dad_attribute had correct type of ".$attribute->type_constraint());
        }
        else {
           fail("Role DAD attribute: $dad_attribute had in correct type of ".$attr->type_constraint().". Should be a ".$attribute->type_constraint());
        }
        ok ($attr->get_write_method eq undef, "Role DAD attribute: $dad_attribute is Read Only")  
    }
    else{
        fail("Role DAD can $dad_attribute");
    }
   
 }






ok( ref($da) eq 'Database::Accessor', "DA is a Database::Accessor" );
ok($da->_ldad->{'Data::Test'} eq 'Database::Accessor::DAD::Test','Load of DAD Test sucessful');

my $result;
my $fake_data_source = Data::Test->new();

ok($da->retrieve( $fake_data_source, $result ));


done_testing();
