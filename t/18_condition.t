#!perl
use Test::More 0.82;
use Test::Fatal;

use Test::More tests => 7;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Condition');
}

my $condition = Database::Accessor::Condition->new(
    {
        predicates => [
            {
                left => {
                    name => 'field-1',
                    view => 'table-1'
                },
                right => {
                    name => 'field-2',
                    view => 'table-1'
                },
                operator => '='
            }
        ]
    }
);

ok( ref($condition) eq 'Database::Accessor::Condition',
    "condition is a Condition" );
isa_ok($condition,"Database::Accessor::Base", "Condition is a Database::Accessor::Base");
ok(
    does_role( $condition, "Database::Accessor::Roles::PredicateArray" ) eq 1,
    "condition does role Database::Accessor::Roles::PredicateArray"
);
ok( ref( $condition->predicates()->[0] ) eq 'Database::Accessor::Predicate',
    "predicated contains a predicate" );
ok( $condition->predicates()->[0]->operator() eq '=',
    "predicat->0 has operator '='" );
