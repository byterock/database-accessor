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
    use_ok('Database::Accessor::If');
    use_ok('Database::Accessor::If::Then');
}

my $when = Database::Accessor::If::Then->new(
    {
        left      => { name  => 'Price', },
        right     => { value => '10' },
        operator  => '<',
        then => { value => 'under 10$' }
    }
);


# exit;
ok( ref($when) eq 'Database::Accessor::If::Then', "when is a when" );
ok(
    does_role( $when, "Database::Accessor::Roles::Comparators" ) eq 1,
    "when does role Database::Accessor::Roles::Comparators"
);

my $case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => { value => 'under 10$' }
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
                    then => { value => '10~30$' }
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
                    then => { value => '30~100$' }
                },
            ],
            { then => { value => 'Over 100$' } },
        ]
    }
);

 # warn("case=".Dumper($case));

ok( ref($case) eq 'Database::Accessor::If', "case is a case" );

ok( ref( $case->ifs->[0] ) eq 'Database::Accessor::If::Then',
    "Ifs->ifs->[0]  is a when" );

ok( ref( $case->ifs->[1] ) eq 'ARRAY',
    "Ifs->ifs->[1]  is an array-ref" );

ok( ref( $case->ifs->[1]->[0] ) eq 'Database::Accessor::If::Then',
    "Ifs->ifs->[1]->[0]   is a when" );


my $last = pop( @{ $case->ifs } );
ok( ref( $last->then ) eq 'Database::Accessor::Param',
    "last then is a Param" );

$case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
            {
                then => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
        ]
    }
);
my $first = shift( @{ $case->ifs } );
ok( ref( $first->then ) eq 'Database::Accessor::Expression',
    "last then is an Expression" );

$last = pop( @{ $case->ifs } );
ok( ref( $last->then ) eq 'Database::Accessor::Expression',
    "last then is an Expression" );

$case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => {
                    function => 'left',
                    left     => { name => 'price' },
                    right    => [ { value => 2 } ]
                }
            },
            {
                then => {
                    function => 'left',
                    left     => { name => 'price' },
                    right    => [ { value => 2 } ]
                },
            }
        ]
    }
);
$first = shift( @{ $case->ifs } );
ok( ref( $first->then ) eq 'Database::Accessor::Function',
    "last then is an Function" );

$last = pop( @{ $case->ifs } );
ok( ref( $last->then ) eq 'Database::Accessor::Function',
    "last then is an Function" );
$case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => { name  => 'price' }
            },
            { then => { name => 'price' } }
        ]
    }
);
$first = shift( @{ $case->ifs } );
ok( ref( $first->then ) eq 'Database::Accessor::Element',
    "last then is an Element" );

$last = pop( @{ $case->ifs } );
ok( ref( $last->then ) eq 'Database::Accessor::Element',
    "last then is an Element" );

$case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => { name  => 'price' }
            },
            {
                then => {
                    ifs => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            then => { name  => 'price' }
                        },
                        { then => { name => 'price' } }
                    ]
                }
            }
        ]
    }
);

$last = pop( @{ $case->ifs } );
ok( ref( $last->then ) eq 'Database::Accessor::If',
    "last then is an If" );

$case = Database::Accessor::If->new(
    {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => {  ifs => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            then => { name  => 'price' }
                        },
                        { then => { name => 'price' } }
                    ] }
            },
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => { value => 'under 10$' }
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
                    then => { name => 'price' }
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
                    then => {
                        function => 'left',
                        left     => { name => 'price' },
                        right    => [ { value => 2 } ]
                    }
                },
            ],
            {
                then => {
                    expression => '-',
                    left       => { name => 'price' },
                    right      => { value => 10 }
                }
            },
        ]
    }
);
 # warn("when=".Dumper($case));
ok( ref( $case->ifs->[0]->then ) eq 'Database::Accessor::If',
    "big when [0] then is a If" );
    
ok( ref( $case->ifs->[1]->then ) eq 'Database::Accessor::Param',
    "big when [1] then is a Param" );
    
ok( ref( $case->ifs->[2])  eq 'ARRAY',
    "big when [2] is an array ref" );

ok( ref( $case->ifs->[2]->[1])  eq 'Database::Accessor::If::Then',
    "big when [2]->[1] is a when" );

ok( ref( $case->ifs->[2]->[1]->then)  eq 'Database::Accessor::Element',
    "big when [2]->[1]->then is an Element" );

ok( ref( $case->ifs->[3])  eq 'ARRAY',
    "big when [3] is an array ref" );

ok( ref( $case->ifs->[3]->[1])  eq 'Database::Accessor::If::Then',
    "big when [3]->[1] is a when" );

ok( ref( $case->ifs->[3]->[1]->then)  eq 'Database::Accessor::Function',
    "big when [3]->[1]->then is an Fucntion" );

ok( ref( $case->ifs->[4]->then ) eq 'Database::Accessor::Expression',
    "big when [4] then is a Expression" );
   

like(exception {Database::Accessor::If->new( {
        ifs => [
            {
                left      => { name  => 'Price', },
                right     => { value => '10' },
                operator  => '<',
                then => {  ifs => [
                        {
                            left      => { name  => 'Price', },
                            right     => { value => '10' },
                            operator  => '<',
                            then => { name  => 'price' }
                        },
                    ] }
            }]})},
                    qr /Validation failed for \'ArrayRefofThens\'/,
                    "If Fails with less than 2 ifs"
                );