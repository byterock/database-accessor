#!perl
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 8;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Function');
    use_ok('Database::Accessor::Expression');
}

my $street = Database::Accessor::Function->new(
    {
        left => {
            name => 'field-1',
            view => 'table-1'
        },
        right => {
            name => 'field-2',
            view => 'table-1'
        },
        function => '='
    }
);

ok( ref($street) eq 'Database::Accessor::Function', "function is a function" );

ok(
    does_role( $street, "Database::Accessor::Roles::Comparators" ) eq 1,
    "predicate does role Database::Accessor::Roles::Base"
);

$street = Database::Accessor::Expression->new(
    {
        left => {
            name => 'field-1',
            view => 'table-1'
        },
        right => {
            name => 'field-2',
            view => 'table-1'
        },
        expression => '+'
    }
);

ok( ref($street) eq 'Database::Accessor::Expression',
    "Street is an expression" );
ok( does_role( $street, "Database::Accessor::Roles::Comparators" ) eq 1,
    "View does role Database::Accessor::Roles::Base" );

ok( $street->expression('/'), 'can do an /' );

# like(
   # exception {$street->aggregate('Avgx');},
   # qr/Can't locate object method "aggregate"/,
 # "the code died as expected with Avgx",
# );

# eval { ok( $street->aggregate('Avgx'), 'can do an Avgx' ); };
# if ($@) {
    # pass("Element aggregate can not be Avgx");
# }
# else {
    # fail("Element aggregate can not be Avgx");
# }
