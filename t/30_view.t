#!perl
use Test::More 0.82;
use Test::Fatal;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Test::More tests => 4;
use Data::Test;
use Test::Deep;
use Test::Fatal;
use Database::Accessor;
use Test::Database::Accessor::Utils;

my $in_hash = {
    view => {
        name  => 'name',
        alias => 'alias'
    },
    elements => [ { name => 'first_name', }, { name => 'last_name', }, ],
};


my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $da->result->error(); #note to others this is a kludge for testing
bless( $in_hash->{view}, "Database::Accessor::View" );

cmp_deeply( $da->view, methods( %{ $in_hash->{view} } ), "DA View is correct" );
cmp_deeply(
    $dad->view,
    methods( %{ $in_hash->{view} } ),
    "DAS View is correct"
);

eval { my $test = $da->{view} };
if ($@) {
    pass("Cannot access attribute directly");
}
else {
    fail("Cannot access attribute directly");
}

eval { $da->{view} = 'somethig'; };
if ($@) {
    pass("Cannot change attribute directly");
}
else {
    fail("Cannot change attribute directly");
}

1;
