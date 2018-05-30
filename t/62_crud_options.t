

#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Data::Test;
use Database::Accessor;
use MooseX::Test::Role;
use Test::More tests => 3;

my @vars = qw(da_warning da_no_effect da_compose_only);


my $in_hash = {
       update_requires_condition=>0,
    delete_requires_condition=>0,
    view     => { name => 'People' },
    elements => [
        {
            name => 'first_name',
            view => 'People'
        },
        {
            name => 'last_name',
            view => 'People'
        },
        {
            name => 'user_id',
            view => 'People'
        }
    ],
};
my $container =  {first_name=>'Bill',
                  last_name =>'Bloggings'};

my $da = Database::Accessor->new($in_hash);
my $data       = Data::Test->new();
$da->retrieve($data,{only_elements=>{first_name=>1,last_name=>1}});
my $dad = $da->result->error(); #note to others this is a kludge for testing
ok($dad->element_count == 2,"Only two elements");
ok($dad->elements->[0]->name() eq 'first_name',"First name in correct place");
ok($dad->elements->[1]->name() eq 'last_name',"Last name in correct place");

