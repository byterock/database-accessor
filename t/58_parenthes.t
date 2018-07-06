#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);

use Data::Dumper;
use Data::Test;

use Database::Accessor;
use Test::Database::Accessor::Utils;
use Test::More tests => 43;
use Test::Fatal;

my $in_hash = {
    view     => { name => 'People' },
    elements => [
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
    conditions => [
        {
            left => {
                name => 'First_1',
                view => 'People'
            },
            right             => { value => 'test->1' },
            operator          => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
        },
        {
            condition => 'AND',
            left      => {
                name => 'First_2',
                view => 'People'
            },
            right             => { value => 'test->2' },
            operator          => '=',
            open_parentheses  => 0,
            close_parentheses => 1
        }
      ]

    ,
};

my $in_hash2 = {
    view     => { name => 'People' },
    elements => [
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
    conditions => [
        {
            left => {
                name => 'First_1',
                view => 'People'
            },
            right             => { value => 'test->3' },
            operator          => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
            condition         => 'AND',
        },
        {
            condition => 'AND',
            left      => {
                name => 'First_2',
                view => 'People'
            },
            right    => { value => 'test->4' },
            operator => '=',

        }
      ]

    ,
};

my $in_hash3 = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
    view                      => { name => 'People' },
    elements                  => [
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
    gather => {
        elements => [
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
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 1,
                close_parentheses => 0,
                condition         => 'AND',
            },
            {
                left => {
                    name => 'first_name',
                    view => 'People'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 0,
                close_parentheses => 1
            }
        ]
    }
};

my $in_hash4 = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
    view                      => { name => 'People' },
    elements                  => [
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
    gather => {
        elements => [
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
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 1,
                close_parentheses => 0,
                condition         => 'AND',
            },
            {
                condition => 'AND',
                left      => {
                    name => 'first_name',
                    view => 'People'
                },
                right             => { value => 'test' },
                operator          => '=',
                open_parentheses  => 0,
                close_parentheses => 0
            }
        ]
    },
};

my $da = Database::Accessor->new($in_hash);

my $return = {};

ok( $da->retrieve( Data::Test->new(), $return ), "Balanced parentheses" );

$da = Database::Accessor->new($in_hash2);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught unbalanced parentheses"
);

$da->add_condition(
    {
        left => {
            name => 'last_name2',
            view => 'People'
        },
        right             => { value => 'test->5' },
        operator          => '=',
        open_parentheses  => 0,
        close_parentheses => 1,
        condition         => 'AND',
    }
);
ok( $da->retrieve( Data::Test->new(), $return ), "Balanced parentheses" );

$da->add_condition(
    {
        left => {
            name => 'last_name2',
            view => 'People'
        },
        right             => { value => 'test->6' },
        operator          => '=',
        open_parentheses  => 1,
        close_parentheses => 0,
        condition         => 'AND',
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught parentheses"
);

$da->add_condition(
    {
        left => {
            name => 'last_name2',
            view => 'People'
        },
        right             => { value => 'test->7' },
        operator          => '=',
        open_parentheses  => 0,
        close_parentheses => 1,
    }
);

$da->retrieve( Data::Test->new(), $return );

ok( !$da->result->error->conditions->[0]->predicates->condition(),
    'AND not added to first condition predicate' );

ok( $da->result->error->conditions->[4]->predicates->condition() eq 'AND',
    'AND added to last condition predicate' );

$da = Database::Accessor->new($in_hash3);

ok( $da->retrieve( Data::Test->new(), $return ), "Balanced parentheses" );
ok( !$da->result->error->gather->conditions->[0]->predicates->condition(),
    'AND not added to first gather condition predicate' );

ok(
    $da->result->error->gather->conditions->[1]->predicates->condition() eq
      'AND',
    'AND added to last gather condition predicate'
);

#$dad = $da->result->error();

# warn("JSP ".Dumper($dad));

$da = Database::Accessor->new($in_hash4);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught unbalanced parentheses"
);

#LEFT 1  = (abs((People.salary + .05) * 1.5))*People.overtime
# +
#RIGHT 1 = (abs(People.salary+.05) *2)*People.doubletime)

#LEFT 2  = (abs((People.salary + .05) * 1.5))
#*
#RIGHT 2 People.overtime

#LEFT 3  = (abs((People.salary + .05) * 1.5))

#NO RIGHT 3

#LEFT 4 = (People.salary + .05)
#*
# LEFT 4 1.5)

#LEFT 5 = (People.salary
#+
#.05)

#The above would be expressed as the following 'element' hash;

my $expression = {
    expression => '+',
    left       => {
        expression        => '*',
        open_parentheses  => 1,
        close_parentheses => 1,
        left              => {
            expression        => '*',
            open_parentheses  => 1,
            close_parentheses => 1,
            left              => {
                function => 'abs',
                left     => {
                    expression => '+',
                    left       => { name => 'salary' },
                    right      => { value => '0.5' }
                },
            },
            right => { value => '1.5' },
        },
        right => { name => 'overtime' },
    },
    right => {
        expression        => '*',
        open_parentheses  => 1,
        close_parentheses => 1,
        left              => {
            expression        => '*',
            open_parentheses  => 1,
            close_parentheses => 1,
            left              => {
                function => 'abs',
                left     => {
                    expression => '+',
                    left       => { name => 'salary' },
                    right      => { value => '0.5' }
                },
            },
            right => { value => '2' },
        },
        right => { name => 'doubletime' },
    },
};
$in_hash = {
    view     => { name => 'People' },
    elements => [$expression]
};

#warn( "JSP " . Dumper($in_hash) );
$da = Database::Accessor->new($in_hash);

ok(
    $da->retrieve( Data::Test->new(), $return ),
    "Balanced nested elements parentheses"
);
delete( $in_hash->{elements}->[0]->{left}->{open_parentheses} );
$da = Database::Accessor->new($in_hash);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught left open parentheses missing"
);

$in_hash->{elements}->[0]->{left}->{open_parentheses} = 1;

delete( $in_hash->{elements}->[0]->{left}->{close_parentheses} );

$da = Database::Accessor->new($in_hash);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught left close parentheses missing"
);

$in_hash->{elements}->[0]->{left}->{close_parentheses} = 1;
delete( $in_hash->{elements}->[0]->{right}->{left}->{close_parentheses} );

$da = Database::Accessor->new($in_hash);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught right left close parentheses missing"
);

$in_hash->{elements}->[0]->{right}->{left}->{close_parentheses} = 1;
delete( $in_hash->{elements}->[0]->{right}->{left}->{open_parentheses} );

$da = Database::Accessor->new($in_hash);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Caught right left open parentheses missing"
);

$in_hash->{elements}->[0]->{right}->{left}->{open_parentheses} = 1;

$in_hash = {
    view     => { name => 'People' },
    elements => [
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
    ]
};
$da = Database::Accessor->new($in_hash);

$da->add_condition(
    {
        left     => $expression,
        right    => { value => '201' },
        operator => '=',
    }
);

ok(
    $da->retrieve( Data::Test->new(), $return ),
    "Balanced nested elements on condition"
);

#$dad = $da->result->error();
ok(
    !$da->result->error->conditions->[0]->predicates->condition(),
    'AND condition not added when only 1 condition in conditions array'
);
$da->reset_conditions();
$da->add_condition(
    {
        left      => $expression,
        right     => { value => '201' },
        operator  => '=',
        condition => 'AND',
    }
);
$da->retrieve( Data::Test->new(), $return );
ok( !$da->result->error->conditions->[0]->predicates->condition(),
'AND condition ignored when present and only 1 condition in conditions array'
);
$da->reset_conditions();
$da->add_condition(
    [
        {
            left     => $expression,
            right    => { value => '201' },
            operator => '=',
        },
        {
            left     => $expression,
            right    => { value => '201' },
            operator => '=',
        }
    ]
);
$da->retrieve( Data::Test->new(), $return );
ok( !$da->result->error->conditions->[0]->predicates->condition(),
    'AND not present on first condition predicate' );

ok( $da->result->error->conditions->[1]->predicates->condition() eq 'AND',
    'AND present on second condition predicate' );

$da->reset_conditions();
delete( $expression->{left}->{open_parentheses} );

$da->add_condition(
    {
        left      => $expression,
        right     => { value => '201' },
        operator  => '=',
        condition => 'AND',
    }
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Conditions caught left open parentheses missing"
);
$da->reset_conditions();
$expression->{left}->{open_parentheses} = 1;
delete( $expression->{left}->{close_parentheses} );
$da->add_condition(
    {
        left      => $expression,
        right     => { value => '201' },
        operator  => '=',
        condition => 'AND',
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Conditions caught left close parentheses missing"
);
$expression->{left}->{close_parentheses} = 1;

$da->reset_conditions();
$expression->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{close_parentheses} );

$da->add_condition(
    {
        left      => $expression,
        right     => { value => '201' },
        operator  => '=',
        condition => 'AND',
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Conditions caught right left close parentheses missing"
);

$da->reset_conditions();
$expression->{right}->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{open_parentheses} );
$da->add_condition(
    {
        left      => $expression,
        right     => { value => '201' },
        operator  => '=',
        condition => 'AND',
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Conditions caught right left open parentheses missing"
);

$expression->{right}->{left}->{open_parentheses} = 1;
$da->reset_conditions();

$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    },
);

ok(
    $da->retrieve( Data::Test->new(), $return ),
    "Balanced nested elements on link"
);

ok( !$da->result->error->links->[0]->conditions->[0]->predicates->condition(),
    'AND not present on first link predicate' );
$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left     => $expression,
                right    => { value => '201' },
                operator => '=',
            },
            {
                left     => $expression,
                right    => { value => '201' },
                operator => '=',
            }
        ]
    }
);
$da->retrieve( Data::Test->new(), $return ),

  #my $dad = $da->result->error();

  ok( !$da->result->error->links->[0]->conditions->[0]->predicates->condition(),
    'AND not present on first link predicate' );

ok( !$da->result->error->links->[1]->conditions->[0]->predicates->condition(),
    'AND not present on second link predicate' );

ok(
    $da->result->error->links->[1]->conditions->[1]->predicates->condition() eq
      'AND',
    'AND added to second link predicate'
);

delete( $expression->{left}->{open_parentheses} );

$da->reset_links();

$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    },
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Link caught left open parentheses missing"
);

$da->reset_links();
$expression->{left}->{open_parentheses} = 1;
delete( $expression->{left}->{close_parentheses} );
$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    },
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Link caught  left close parentheses missing"
);
$expression->{left}->{close_parentheses} = 1;

$da->reset_links();
$expression->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{close_parentheses} );

$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    },
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Link caught  right left close parentheses missing"
);

$da->reset_links();
$expression->{right}->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{open_parentheses} );
$da->add_link(
    {
        to => {
            name  => 'country',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    },
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Link caught  right left open parentheses missing"
);

$da->reset_links();
$expression->{right}->{left}->{open_parentheses} = 1;

$da->add_gather(
    {
        elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
        ],
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    }
);

ok(
    $da->retrieve( Data::Test->new(), $return ),
    "Balanced nested elements on Gather"
);

$da->reset_gather();
delete( $expression->{left}->{open_parentheses} );

$da->add_gather(
    {
        elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
        ],
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    }
);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Gather caught left open parentheses missing"
);

$da->reset_gather();
$expression->{left}->{open_parentheses} = 1;
delete( $expression->{left}->{close_parentheses} );
$da->add_gather(
    {
        elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
        ],
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Gather caught  left close parentheses missing"
);
$expression->{left}->{close_parentheses} = 1;

$da->reset_gather();
$expression->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{close_parentheses} );
$da->add_gather(
    {
        elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
        ],
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Gather caught  right left close parentheses missing"
);

$da->reset_gather();
$expression->{right}->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{open_parentheses} );
$da->add_gather(
    {
        elements => [
            {
                name => 'first_name',
                view => 'People4'
            },
        ],
        conditions => [
            {
                left      => $expression,
                right     => { value => '201' },
                operator  => '=',
                condition => 'AND',
            }
        ]
    }
);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Gather caught  right left open parentheses missing"
);

$da->reset_gather();
$expression->{right}->{left}->{open_parentheses} = 1;

$da->add_sort($expression);

ok(
    $da->retrieve( Data::Test->new(), $return ),
    "Balanced nested elements on Sort"
);

$da->reset_sorts();

delete( $expression->{left}->{open_parentheses} );

$da->add_sort($expression);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Sort caught left open parentheses missing"
);

$da->reset_sorts();
$expression->{left}->{open_parentheses} = 1;
delete( $expression->{left}->{close_parentheses} );

$da->add_sort($expression);
like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Sort caught  left close parentheses missing"
);
$expression->{left}->{close_parentheses} = 1;

$da->reset_sorts();
$expression->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{close_parentheses} );
$da->add_sort($expression);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Sort caught  right left close parentheses missing"
);

$da->reset_sorts();
$expression->{right}->{left}->{close_parentheses} = 1;
delete( $expression->{right}->{left}->{open_parentheses} );

$da->add_sort($expression);

like(
    exception { $da->retrieve( Data::Test->new() ) },
    qr /Unbalanced parentheses in your static or dynamic attributes/,
    "Sort caught  right left open parentheses missing"
);
