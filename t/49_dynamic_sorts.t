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
}

my $in_hash = {
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

my $da = Database::Accessor->new( { view => { name => 'People' } } );

foreach my $sort ( @{ $in_hash->{sorts} } ) {
    ok( $da->add_sort($sort), "can add an single Dynamic sort" );
}

# warn("DA 1=".Dumper($da));
$return_str = {};
$da->retrieve( Data::Test->new(), $return_str );

$dad = $return_str->{dad};

Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->dynamic_sorts, 'dynamic sorts'
);

ok(
    $da->add_sort( @{ $in_hash->{sort} } ),
    "can add an Array of Dynamic sorts"
);

$da->retrieve( Data::Test->new(), $return_str );
$dad = $return_str->{dad};
Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->dynamic_sorts, 'Array of dynamic sorts'
);

ok( $da->add_sort( $in_hash->{sort} ),
    "can add an Array Ref of Dynamic sorts" );

$dad = $da->retrieve( Data::Test->new(), $return_str );
$dad = $return_str->{dad};
Test::Database::Accessor::Utils::deep_element(
    $in_hash->{sorts},   $da->dynamic_sorts,
    $dad->dynamic_sorts, 'Array Ref of dynamic sorts'
);
