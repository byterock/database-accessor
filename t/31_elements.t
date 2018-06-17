#!perl
use strict;
use warnings;

use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 39;


my $in_hash = {
     
    view     => { name => 'People' },
    elements => [
        {
            name  => 'first_name',
            #view  => 'People',
            #alias => 'user'
        },
        {
            name  => 'last_name',
            view  => 'People',
            alias => 'user'
        },
        {
            name  => 'user_id',
            view  => 'People',
            alias => 'user'
        },
       
    ],
};

my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing
ok($dad->elements->[0]->view eq 'People', "View taked from DA view name");

Test::Database::Accessor::Utils::deep_element( $in_hash->{elements},
    $da->elements, $dad->elements, 'Element' );

       
$in_hash->{delete_requires_condition} = 0;
$in_hash->{update_requires_condition} = 0; 
$in_hash->{elements}->[0]->{no_retrieve} = 1;
$in_hash->{elements}->[1]->{no_create}   = 1;
$in_hash->{elements}->[2]->{no_update}   = 1;

$da = Database::Accessor->new($in_hash);
$da->retrieve( Data::Test->new(), $return );
$dad = $da->result->error();
ok($dad->element_count == 2,"only two Elements retrieve");
ok($dad->elements->[0]->name eq 'last_name',"last_name is index 0");
ok($dad->elements->[1]->name eq 'user_id',"user_id is index 1");

delete($in_hash->{elements}->[0]->{no_retrieve});
$in_hash->{elements}->[0]->{only_retrieve} = 1;

$da->create( Data::Test->new(), {test=>1} );
$dad = $da->result->error();
ok($dad->element_count == 1,"only one Element on create");
ok($dad->elements->[0]->name eq 'user_id',"user_id is index 0");

$da->update( Data::Test->new(), {test=>1} );
$dad = $da->result->error();
ok($dad->element_count == 1,"only one Element on create");
ok($dad->elements->[0]->name eq 'last_name',"last_name is index 0");

push(@{$in_hash->{elements}},{value =>'static data'});
# warn("dat=".Dumper($in_hash));

 $da = Database::Accessor->new($in_hash);
 $da->create( Data::Test->new(), {test=>1} );
 $dad = $da->result->error();
 ok($dad->element_count == 1,"only 1 on create");
 $da->retrieve( Data::Test->new() );
 $dad = $da->result->error();
 ok($dad->element_count == 4,"4 Elements on retrieve");
 $dad = $da->result->error();
 ok(ref($dad->elements->[3]) eq 'Database::Accessor::Param','4th element is a Param class');
 $da->update( Data::Test->new(), {test=>1} );
 $dad = $da->result->error();
 ok($dad->element_count == 1,"only 1 on update");
 $da->delete( Data::Test->new() );
 $dad = $da->result->error();
 ok($dad->element_count == 0,"none on delete");
 
 
 $in_hash->{elements} = [{ function => 'left',
                                 left  => { name => 'salary' },
                                 right => { expression => '*',
                                                 left  => { name => 'bonus' },
                                                 right => { param=>.05 }} },
                          { function => 'abs',
                                 left  => { expression => '*',
                                                 left  => { name => 'bonus',
                                                            view => 'Other' },
                                                 right => { param=>-.05 }} },
                          { expression => '+',
                                 left  => { name => 'salary',
                                            view => 'NotPeople' },
                                 right => { expression => '*',
                                                 left  => { name => 'bonus',
                                                            },
                                                 right => { function => 'abs',
                                                                left => { expression => '*',
                                                                                left => { name => 'bonus',
                                                                                          view => 'Other' },
                                                                               right => { name => 'bonus' }} }} 
                           }];

 $da     = Database::Accessor->new($in_hash);
 
 $da->retrieve( Data::Test->new() );
 $dad = $da->result->error();
 
 ok(ref($dad->elements->[0]) eq 'Database::Accessor::Function','Element 0 is an function');
 ok($dad->elements->[0]->left->view eq 'People','function left has correct view');
 ok(ref($dad->elements->[0]->right) eq 'Database::Accessor::Expression','Element 0 right is an expression');
 ok($dad->elements->[0]->right->left->view eq 'People','Element 0 right expression right has correct view');

 ok(ref($dad->elements->[1]->left) eq 'Database::Accessor::Expression','Element 1 right is an expression');
 ok($dad->elements->[1]->left->left->view eq 'Other','Function 1 left has correct view');
 ok(!$dad->elements->[1]->right,'No Element 1 right');

 ok(ref($dad->elements->[2]) eq 'Database::Accessor::Expression','Element 2 is an expression');
 ok($dad->elements->[2]->left->view eq 'NotPeople','Function 2 left has correct view');
 ok(ref($dad->elements->[2]->right) eq 'Database::Accessor::Expression','Element 2 right is an expression');
 ok(ref($dad->elements->[2]->right->left) eq 'Database::Accessor::Element','Element 2 right->left is an element');
 ok($dad->elements->[2]->right->left->view eq 'People','Function 2 right->left has correct view');
 
 ok(ref($dad->elements->[2]->right->right) eq 'Database::Accessor::Function','Element 2 right->right is an functuion');
 ok(ref($dad->elements->[2]->right->right->left) eq 'Database::Accessor::Expression','Element 2 right->right->left is an Epresion');
 ok($dad->elements->[2]->right->right->left->left->view eq 'Other','Function 2 right->right->left has correct view');
 ok(!$dad->elements->[2]->right->right->right,'No Element 2 right->right->right');
 ok(ref($dad->elements->[2]->right->right->left->left) eq 'Database::Accessor::Element','Element 2 right->right->left->left is an Element');
 ok($dad->elements->[2]->right->right->left->left->view eq 'Other','Function 2 right->right->left->left has correct view');
 ok(ref($dad->elements->[2]->right->right->left->right) eq 'Database::Accessor::Element','Element 2 right->right->left->right is an Element');
 ok($dad->elements->[2]->right->right->left->right->view eq 'People','Function 2 right->right->left->right has correct view');
 




 
 
 

1;
