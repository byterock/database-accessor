#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('..\t\lib');
use Data::Dumper;
use Data::Test;
use Test::Database::Accessor::Utils;
use Test::Deep;
use Test::More tests => 3;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";
}

my $in_hash = {
    view     => { name => 'People' },
    elements => [
        {
            name  => 'first_name',
            view  => 'People',
            alias => 'user'
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
my $dad = $return->{dad};

Test::Database::Accessor::Utils::deep_element( $in_hash->{elements},
    $da->elements, $dad->elements, 'Element' );
1;
