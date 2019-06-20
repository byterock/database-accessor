#!perl
use Test::More 0.82;
use Test::Fatal;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);

use Data::Dumper;
use Test::More tests => 39;
use Data::Test;
use Test::Deep;
use Test::Fatal;
use Database::Accessor;
use Test::Database::Accessor::Utils;

my $da;

like(
    exception { $da = Database::Accessor->new( {} ); },
    qr /The following Attributes are required: \(elements,view\)/,
    "View and Elements required"
);

$in_hash = {
    view => {
        name  => undef,
        alias => undef
    }
};

eval { $da = Database::Accessor->new($in_hash); };

ok( $@->has_errors(),          "Error on new invalid" );
ok( scalar( $@->errors ) == 1, "Single error on new invalid" );
my @errors = $@->errors;
ok( ref( $errors[0] ) eq 'MooseX::Constructor::AllErrors::Error::Misc',
    "Got single Misc error" );
ok(
    index( $errors[0]->message,
        "'view->name' Constraint: Validation failed for 'Str' with value undef"
      ) > -1,
    'view->name validation present'
);

ok(
    index( $errors[0]->message,
        "'view->alias' Constraint: Validation failed for 'Str' with value undef"
      ) > -1,
    'view->alias validation present'
);

$ENV{DA_ALL_ERRORS} = 1;

eval { $da = Database::Accessor->new($in_hash); };

ok( scalar( $@->errors ) == 2, "Two errors on new when DA_ALL_ERRORS is one" );
my @errors = $@->errors;
ok( $errors[0]->attribute->name() == 'name',  "View: param name fails" );
ok( $errors[1]->attribute->name() == 'alias', "View: param alias fails" );

$in_hash = {
    view => { name => 'People' },
    elements => [ { name => 'first_name', }, { name => 'last_name', }, ],

};

$ENV{DA_ALL_ERRORS} = 0;

$da = Database::Accessor->new($in_hash);

my $tests = {
    conditions => [
        {
            caption    => 'Left is required',
            exception  => "\(conditions->left\)",
            conditions => {
                leftx => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => '=',
            }
        },
        {
            caption    => 'operator not undef',
            exception  => "\(conditions->operator\)",
            conditions => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => undef,
            }
        },
        {
            caption    => 'right not undef',
            exception  => "\(conditions->right\)",
            conditions => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => undef,
                operator => '=',
            }
        },
        {
            caption    => 'condtion must be an operator',
            exception  => "\(conditions->condition\)",
            conditions => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right     => { value => 'test' },
                operator  => '=',
                condition => "xx"
            }
        }
    ],
    gather => [
        {
            caption   => 'Elements is required',
            exception => "gather->elements",
            gather    => {
                elements   => undef,
                conditions => [
                    {
                        left => {
                            name => 'last_name',
                            view => 'People7'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 1,
                        close_parentheses => 0,
                        condition         => 'AND',
                    },
                ]
            }
        },
        {
            caption   => 'Elements is required',
            exception => "\(gather->elements\)",
            gather    => {
                elementsq => [
                    {
                        name => 'first_name',
                        view => 'People4'
                    },
                ],
                conditions => [
                    {
                        left => {
                            name => 'last_name',
                            view => 'People7'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 1,
                        close_parentheses => 0,
                        condition         => 'AND',
                    },
                ]
            }
        },
        {
            caption   => 'conditions is required',
            exception => "\(conditions->left\)",
            gather    => {
                elements => [
                    {
                        name => 'first_name',
                        view => 'People4'
                    },
                ],
                conditions => [
                    {
                        left_failx => {
                            name => 'last_name',
                            view => 'People7'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 1,
                        close_parentheses => 0,
                        condition         => 'AND',
                    },
                ]
            }
        }
    ],
    links => [
        {
            caption   => 'to is required',
            exception => "\(view->name\)",
            links     => {
                toz => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'Left',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 1,
                        close_parentheses => 0,
                    }
                ]
            }
        },
        {
            caption   => 'to not empty',
            exception => "\(view->name\)",
            links     => {
                to         => {},
                type       => 'Left',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 1,
                        close_parentheses => 0,
                    }
                ]
            }
        },
        {
            caption   => 'type is required',
            exception => "\(links->type\)",
            links     => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                typez      => 'Left',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1,
                    }
                ]
            }
        },
        {
            caption   => 'type is proper link ',
            exception => "The Link 'bla'",
            links     => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'bla',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1,
                    }
                ]
            }
        },
        {
            caption   => 'conditions is required',
            exception => "\(links->conditions\)",
            links     => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type        => 'Left',
                conditionsx => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator => '=',
                    }
                ]
            }
        },
        {
            caption   => 'conditions cannot be empty',
            exception => "\(links->conditions\)",
            links     => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'Left',
                conditions => []
            }
        },
    ],
    sorts => [
        {
            caption   => 'name required',
            exception => "\(name\)",
            sorts     => [
                {
                    namex => 'first_name',
                    view  => 'People'
                },
            ]
        },

    ],

};

# $in_hash->{links} = $tests->{links}->[2]->{links};
# warn(Dumper($in_hash)); # $da = Database::Accessor->new($in_hash);

# warn(Dumper($da->links)); # exit;
# $tests ={};
$ENV{DA_ALL_ERRORS} = 0;
foreach my $in_key ( sort( keys( %{$tests} ) ) ) {
    foreach my $test ( @{ $tests->{$in_key} } ) {
        $in_hash->{$in_key} = $test->{$in_key};

        like(
            exception { $da = Database::Accessor->new($in_hash) },
            qr /$test->{exception}/,
            "$test->{caption}; $in_key"
        );

        #  $da = Database::Accessor->new($in_hash);
        delete( $in_hash->{$in_key} );
    }
}

# exit;
$tests = {
    condition => [
        {
            caption   => 'Left is required',
            exception => "\(conditions->left\)",
            condition => {
                leftx => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => '=',
            }
        },
        {
            caption   => 'operator not correct',
            exception => "\(conditions->operator\)",
            condition => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => 'zz',
            }
        },
        {
            caption   => 'no undef on ',
            exception => "You cannot add 'undef' with add_condition",
            condition => undef
        },
        {
            caption   => 'operator not undef',
            exception => "\(conditions->operator\)",
            condition => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right    => { value => 'test' },
                operator => undef,
            }
        },
        {
            caption   => 'condtion must be an operator',
            exception => "conditions->condition",
            condition => {
                left => {
                    name => 'last_name',
                    view => 'People'
                },
                right     => { value => 'test' },
                operator  => '=',
                condition => "xx"
            }
        },
        {
            caption   => 'too few ifs ',
            exception => "with less than 2 ifs",
            condition => {
                left => {
                    name => 'second_1',
                    view => 'People'
                },
                right => {
                    ifs => [
                        {
                            left     => { name  => 'Price', },
                            right    => { value => '10' },
                            operator => '<',
                            then     => { name  => 'price' }
                        },
                    ]
                },
                operator => '=',
            }
        },
    ],

    sort => [
        {
            caption   => 'undef not allowed ',
            exception => "You cannot add 'undef' with add_sort",
            sort      => undef
        },
        {
            caption   => 'name required',
            exception => " does not pass the type constraint becaus",
            sort      => [
                {
                    namex => 'first_name',
                    view  => 'People'
                },
            ]
        },

    ],
    link => [
        {
            caption   => 'undef not allowed ',
            exception => "You cannot add 'undef' with add_link",
            link      => undef
        },
        {
            caption   => 'condtions required',
            exception => "The Link 'bla'",
            link      => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'bla',
                conditions => undef
            }
        },
        {
            caption   => 'conditions icorrect',
            exception => "The Link 'bla'",
            link      => {
                to => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'bla',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1,
                    }
                ]
            }
        },
        {
            caption   => 'To required',
            exception => "view->name",
            link      => {
                tox => {
                    name  => 'country',
                    alias => 'a_country'
                },
                type       => 'bla',
                conditions => [
                    {
                        left => {
                            name => 'country_id',
                            view => 'People'
                        },
                        right => {
                            name => 'id',
                            view => 'a_country'
                        },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1,
                    }
                ]
            }
        }
    ],
    gather => [
        {
            caption   => 'undef not allowed ',
            exception => "You cannot add undef with add_gather",
            gather    => undef
        },
        {
            caption   => 'element required',
            exception => "does not pass the type constraint because",
            gather    => {
                elements      => undef,
                view_elements => [
                    {
                        name => 'first_name',
                        view => 'People4'
                    },
                    {
                        name => 'last_name',
                        view => 'People5'
                    },
                    {
                        function => 'count',
                        left     => {
                            name => 'user_id',
                            view => 'People6'
                        }
                    }
                ],
                conditions => [
                    {
                        left => {
                            name => 'last_name',
                            view => 'People7'
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
                            view => 'People8'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1
                    }
                ]
            }
        },
        {
            caption => 'bad element ',
            exception =>
"does not pass the type constraint because: Validation failed for 'Gather|Undef",
            gather => {
                elements => [
                    {
                        namex => 'first_name',
                        view  => 'People4'
                    },
                ],
                conditions => [
                    {
                        left => {
                            name => 'last_name',
                            view => 'People7'
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
                            view => 'People8'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1
                    }
                ]
            }
        },
        {
            caption => 'bad condtions ',
            exception =>
"does not pass the type constraint because: Validation failed for",
            gather => {
                elements => [
                    {
                        name => 'first_name',
                        view => 'People4'
                    },
                ],
                conditions => [
                    {
                        leftx => {
                            name => 'last_name',
                            view => 'People7'
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
                            view => 'People8'
                        },
                        right             => { value => 'test' },
                        operator          => '=',
                        open_parentheses  => 0,
                        close_parentheses => 1
                    }
                ]
            }
        }
    ],
};

# $da = Database::Accessor->new($in_hash);
foreach my $in_key ( sort( keys( %{$tests} ) ) ) {
    foreach my $test ( @{ $tests->{$in_key} } ) {

        my $new_da = Database::Accessor->new(
            {
                view => { name => 'People' },
                elements =>
                  [ { name => 'first_name', }, { name => 'last_name', }, ]
            }
        );

        # my $reset = "reset_$in_key" . "s";
        my $add = "add_$in_key";

        # $da->$reset()
        # unless ($in_key eq 'gather');

        # warn(" da->$add(".Dumper($test->{$in_key}).")");

        like(
            exception {
                $new_da->$add( $in_key eq 'gather'
                    ? %{ $test->{$in_key} }
                    : $test->{$in_key} );
            },
            qr /$test->{exception}/,
            "$test->{caption} add_$in_key"
        );

        # delete( $in_hash->{$in_key} );
    }
}
1;
