#!perl
use strict;
use warnings;

use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 19;


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
 
 
 




1;
