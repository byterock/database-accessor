#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;

use Test::More tests => 6;
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;
use Data::Test;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";
    use_ok('Database::Accessor::Link');
}

my $in_hash = {
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
    sorts => [
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

my $da         = Database::Accessor->new($in_hash);
my $return_str = {};
my $data       = Data::Test->new();

$da->retrieve(Data::Test->new(),$return_str);
my $dad = $return_str->{dad};

Test::Database::Accessor::Utils::deep_element($in_hash->{sorts},$da->sorts,$dad->sorts,'Sorts');


 $in_hash = {
    view     => { name => 'People' },
    sorts => undef
   };
    eval {
      $da = Database::Accessor->new({});
    };
    if ($@){
       pass("sorts cannot be undef");
       ok(ref($@) eq 'MooseX::Constructor::AllErrors::Error::Constructor','Got error Constructor object');
    }
    else {
      fail("View is Required");     
    }