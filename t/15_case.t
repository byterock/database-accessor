#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::More tests => 2;
use Moose::Util qw(does_role);
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);
use Database::Accessor;

BEGIN {
    use_ok('Database::Accessor::Case');
    use_ok('Database::Accessor::Case::When');
}

my $when = Database::Accessor::Case::When->new(
    {
        left       => { name  => 'Price', },
        right      => { value => '10' },
        operator   => '<',
        expression => { value => 'under 10$' }
    }
);

ok( ref($when) eq 'Database::Accessor::Case::When', "when is a when" );
ok(
    does_role( $when, "Database::Accessor::Roles::Comparators" ) eq 1,
    "when does role Database::Accessor::Roles::Comparators"
);

my $case = Database::Accessor::Case->new(
    {
        case => [
            {
                left       => { name  => 'Price', },
                right      => { value => '10' },
                operator   => '<',
                expression => { value => 'under 10$' }
            },
            [
                {
                    left     => {'Price'},
                    right    => { value => '10' },
                    operator => '>=',
                },
                {
                    condition  => 'and',
                    left       => { name => 'Price' },
                    right      => { value => '30' },
                    operator   => '<=',
                    expression => { value => '10~30$' }
                },
            ],
            [
                {
                    left     => {'Price'},
                    right    => { value => '30' },
                    operator => '>',
                },
                {
                    condition  => 'and',
                    left       => { name => 'Price' },
                    right      => { value => '100' },
                    operator   => '<=',
                    expression => { value => '30~100$' }
                },
            ],
            { expression => { value => 'Over 100$' } },
        ]
    }
);

ok( ref($case) eq ' Database::Accessor::Case', "when is a when" );

ok( ref( $case->cases->[0] ) eq ' Database::Accessor::Case::When',
    "Cases[0]  is a when" );
