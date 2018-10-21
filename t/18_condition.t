#!perl
use Test::More 0.82;
use Test::Fatal;
use lib ('..\lib');
use Test::More tests => 6;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Condition');
}

my $condition = Database::Accessor::Condition->new(
    {
        predicates => 
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
        
    }
);


ok( ref($condition) eq 'Database::Accessor::Condition',
    "condition is a Condition" );
isa_ok($condition,"Database::Accessor::Base", "Condition is a Database::Accessor::Base");
ok( ref( $condition->predicates() ) eq 'Database::Accessor::Predicate',
    "predicated contains a predicate" );
ok( $condition->predicates()->operator() eq '=',
    "predicat->0 has operator '='" );
