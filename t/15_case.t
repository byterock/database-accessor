#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::More tests => 6;
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
        message => { value => 'under 10$' }
    }
);
# warn("when=".Dumper($when));
# exit;
ok( ref($when) eq 'Database::Accessor::Case::When', "when is a when" );
ok(
    does_role( $when, "Database::Accessor::Roles::Comparators" ) eq 1,
    "when does role Database::Accessor::Roles::Comparators"
);

my $case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left       => { name  => 'Price', },
                right      => { value => '10' },
                operator   => '<',
                message => { value => 'under 10$' }
            },
            [
                {
                    left     => { name  =>'Price'},
                    right    => { value => '10' },
                    operator => '>=',
                },
                {
                    condition  => 'and',
                    left       => { name => 'Price' },
                    right      => { value => '30' },
                    operator   => '<=',
                    message => { value => '10~30$' }
                },
            ],
            [
                {
                    left     => { name  => 'Price'},
                    right    => { value => '30' },
                    operator => '>',
                },
                {
                    condition  => 'and',
                    left       => { name => 'Price' },
                    right      => { value => '100' },
                    operator   => '<=',
                    message => { value => '30~100$' }
                },
            ],
            { message => { value => 'Over 100$' } },
        ]
    }
);


# warn("case=".Dumper($case));
ok( ref($case) eq 'Database::Accessor::Case', "case is a case" );

ok( ref( $case->whens->[0] ) eq 'Database::Accessor::Case::When',
    "Cases[0]  is a when" );

ok( ref( $case->whens->[0] ) eq 'Database::Accessor::Case::When',
    "Cases[0]  is a when" );