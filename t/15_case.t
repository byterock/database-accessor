#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::More tests => 26;
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
        left      => { name  => 'Price', },
        right     => { value => '10' },
        operator  => '<',
        statement => { value => 'under 10$' }
    }
);


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
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => { value => 'under 10$' }
            },
            [
                {
                    left     => { name  => 'Price' },
                    right    => { value => '10' },
                    operator => '>=',
                },
                {
                    condition => 'and',
                    left      => { name => 'Price' },
                    right     => { value => '30' },
                    operator  => '<=',
                    statement => { value => '10~30$' }
                },
            ],
            [
                {
                    left     => { name  => 'Price' },
                    right    => { value => '30' },
                    operator => '>',
                },
                {
                    condition => 'and',
                    left      => { name => 'Price' },
                    right     => { value => '100' },
                    operator  => '<=',
                    statement => { value => '30~100$' }
                },
            ],
            { statement => { value => 'Over 100$' } },
        ]
    }
);

 # warn("case=".Dumper($case));

ok( ref($case) eq 'Database::Accessor::Case', "case is a case" );

ok( ref( $case->whens->[0] ) eq 'Database::Accessor::Case::When',
    "Cases->whens->[0]  is a when" );

ok( ref( $case->whens->[1] ) eq 'ARRAY',
    "Cases->whens->[1]  is an array-ref" );

ok( ref( $case->whens->[1]->[0] ) eq 'Database::Accessor::Case::When',
    "Cases->whens->[1]->[0]   is a when" );


my $last = pop( @{ $case->whens } );
ok( ref( $last->statement ) eq 'Database::Accessor::Param',
    "last statement is a Param" );

$case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
            {
                statement => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
        ]
    }
);
my $first = shift( @{ $case->whens } );
ok( ref( $first->statement ) eq 'Database::Accessor::Expression',
    "last statement is an Expression" );

$last = pop( @{ $case->whens } );
ok( ref( $last->statement ) eq 'Database::Accessor::Expression',
    "last statement is an Expression" );

$case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => {
                    function => 'left',
                    left     => { name => 'price' },
                    right    => [ { value => 2 } ]
                }
            },
            {
                statement => {
                    function => 'left',
                    left     => { name => 'price' },
                    right    => [ { value => 2 } ]
                },
            }
        ]
    }
);
$first = shift( @{ $case->whens } );
ok( ref( $first->statement ) eq 'Database::Accessor::Function',
    "last statement is an Function" );

$last = pop( @{ $case->whens } );
ok( ref( $last->statement ) eq 'Database::Accessor::Function',
    "last statement is an Function" );
$case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => { name  => 'price' }
            },
            { statement => { name => 'price' } }
        ]
    }
);
$first = shift( @{ $case->whens } );
ok( ref( $first->statement ) eq 'Database::Accessor::Element',
    "last statement is an Element" );

$last = pop( @{ $case->whens } );
ok( ref( $last->statement ) eq 'Database::Accessor::Element',
    "last statement is an Element" );

$case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => { name  => 'price' }
            },
            {
                statement => {
                    whens => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            statement => { name  => 'price' }
                        },
                        { statement => { name => 'price' } }
                    ]
                }
            }
        ]
    }
);

$last = pop( @{ $case->whens } );
ok( ref( $last->statement ) eq 'Database::Accessor::Case',
    "last statement is an Case" );

$case = Database::Accessor::Case->new(
    {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => {  whens => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            statement => { name  => 'price' }
                        },
                        { statement => { name => 'price' } }
                    ] }
            },
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => { value => 'under 10$' }
            },
            [
                {
                    left     => { name  => 'Price' },
                    right    => { value => '10' },
                    operator => '>=',
                },
                {
                    condition => 'and',
                    left      => { name => 'Price' },
                    right     => { value => '30' },
                    operator  => '<=',
                    statement => { name => 'price' }
                },
            ],
            [
                {
                    left     => { name  => 'Price' },
                    right    => { value => '30' },
                    operator => '>',
                },
                {
                    condition => 'and',
                    left      => { name => 'Price' },
                    right     => { value => '100' },
                    operator  => '<=',
                    statement => {
                        function => 'left',
                        left     => { name => 'price' },
                        right    => [ { value => 2 } ]
                    }
                },
            ],
            {
                statement => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
        ]
    }
);
 # warn("when=".Dumper($case));
ok( ref( $case->whens->[0]->statement ) eq 'Database::Accessor::Case',
    "big when [0] statement is a Case" );
    
ok( ref( $case->whens->[1]->statement ) eq 'Database::Accessor::Param',
    "big when [1] statement is a Param" );
    
ok( ref( $case->whens->[2])  eq 'ARRAY',
    "big when [2] is an array ref" );

ok( ref( $case->whens->[2]->[1])  eq 'Database::Accessor::Case::When',
    "big when [2]->[1] is a when" );

ok( ref( $case->whens->[2]->[1]->statement)  eq 'Database::Accessor::Element',
    "big when [2]->[1]->statement is an Element" );

ok( ref( $case->whens->[3])  eq 'ARRAY',
    "big when [3] is an array ref" );

ok( ref( $case->whens->[3]->[1])  eq 'Database::Accessor::Case::When',
    "big when [3]->[1] is a when" );

ok( ref( $case->whens->[3]->[1]->statement)  eq 'Database::Accessor::Function',
    "big when [3]->[1]->statement is an Fucntion" );

ok( ref( $case->whens->[4]->statement ) eq 'Database::Accessor::Expression',
    "big when [4] statement is a Expression" );
   

like(exception {Database::Accessor::Case->new( {
        whens => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                statement => {  whens => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            statement => { name  => 'price' }
                        },
                    ] }
            }]})},
                    qr /Validation failed for \'ArrayRefofWhens\'/,
                    "Case Fails with less than 2 whens"
                );