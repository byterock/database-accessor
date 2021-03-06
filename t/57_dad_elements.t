#!perl
use strict;
use warnings;

use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 58;
my $in_hash = {
    view     => { name => 'People' },
    elements => [
        { name => 'first_name', },
        {
            name => 'last_name',
            view => 'other'
        },
         {
            function => 'left',
            left     => { name => 'salary' },
            right    => {
                expression => '*',
                left       => { name => 'bonus' },
                right      => { param => .05 }
            }
        },
        {
            function => 'abs',
            left     => {
                expression => '*',
                left       => {
                    name => 'bonus',
                    view => 'Other'
                },
                right => { param => -.05 }
            }
        },
        {
            expression => '+',
            left       => { name => 'salary', },
            right      => {
                expression => '*',
                left       => { name => 'bonus', },
                right      => {
                    function => 'abs',
                    left     => {
                        expression => '*',
                        left       => {
                            name => 'bonus',
                            view => 'Other'
                        },
                        right => { name => 'bonus', }
                    }
                }
            }
        },
          { name => 'user_id', },
        { name => 'salary', },
        { name => 'bonus', },
        { name => 'country_id', },
         { name => 'bonus',
         view=>'Other' },
        { name => 'id',
         view=>'a_country' },
        { name => 'first_name',
         view=>'a_country' },
        { name => 'bonus',
         view=>'a_country' },
       
       
    ],
    conditions => [
        {
            left => {
                name => 'First_1',
                view => 'Other'
            },
            right     => { name => 'test' },
            operator  => '=',
            condition => 'AND',
        },
        {
            condition => 'AND',
            left      => { name => 'first_name', },
            right     => {
                name => 'first_name',
                view => 'other'
            },
            operator => '=',
        },
        {
            condition => 'AND',
            left      => {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => {
                        name => 'bonus',
                        view => 'Other'
                    },
                    right => { param => -.05 }
                }
            },
            right    => { name => 'first_name', },
            operator => '=',
        },
    ],
    links => {
        to => {
            name  => 'country_hash2_link',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left  => { name => 'country_id',
                           view => 'People' },
                right => {
                    name => 'id',
                },
                operator          => '=',
                condition         => 'AND',
            },
            {
                condition => 'AND',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus',
                                    view => 'People' },
                    right      => {
                        function => 'abs',
                        left     => {
                            expression => '*',
                            left       => {
                                name => 'bonus',
                                view => 'Other'
                            },
                            right => { name => 'bonus', }
                        }
                    }
                },
                right    => { name => 'first_name', },
                operator => '=',
            }
        ],
    },
    sorts => [
        { name => 'first_name', },
        {
            name => 'last_name',
            view => 'other'
        },
        {
            function => 'left',
            left     => { name => 'salary' },
            right    => {
                expression => '*',
                left       => { name => 'bonus' },
                right      => { param => .05 }
            }
        },
        {
            function => 'abs',
            left     => {
                expression => '*',
                left       => {
                    name => 'bonus',
                    view => 'Other'
                },
                right => { param => -.05 }
            }
        },
        {
            expression => '+',
            left       => { name => 'salary', },
            right      => {
                expression => '*',
                left       => { name => 'bonus', },
                right      => {
                    function => 'abs',
                    left     => {
                        expression => '*',
                        left       => {
                            name => 'bonus',
                            view => 'Other'
                        },
                        right => { name => 'bonus', }
                    }
                }
            }
        }
    ],
    gather => {
        elements => [
            { name => 'first_name', },
            {
                name => 'last_name',
                view => 'Other People'
            },
        ],
        conditions => [
            {
                left      => { name  => 'last_name', },
                right     => { value => 'test' },
                operator  => '=',
                condition => 'AND',
            },
            {
                condition => 'AND',
                left      => {
                    name => 'first_name',
                    view => 'Not People'
                },
                right    => { value => 'test' },
                operator => '=',
            }
        ]
    },
};

my $da = Database::Accessor->new($in_hash);

$da->add_gather(
    {
        elements  => [ { name => 'user_id', } ],
        conditions => {
            condition => 'AND',
            left      => {
                expression => '*',
                left       => { name => 'bonus', },
                right      => {
                    function => 'abs',
                    left     => {
                        expression => '*',
                        left       => {
                            name => 'bonus',
                            view => 'Other'
                        },
                        right => { name => 'bonus', }
                    }
                }
            },
            right    => { name => 'first_name', },
            operator => '=',
        }
    }
);

$da->add_condition(
    {
        condition => 'AND',
        left      => {
            expression => '*',
            left       => { name => 'bonus',
                            view => 'People' },
            right      => {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => {
                        name => 'bonus',
                        view => 'Other'
                    },
                    right => { name => 'bonus', }
                }
            }
        },
        right    => { name => 'first_name', },
        operator => '=',
    }
);
$da->add_link(
    {
        to => {
            name  => 'country_hash2_link',
            alias => 'a_country'
        },
        type       => 'Left',
        conditions => [
            {
                left  => { name => 'country_id', 
                           view => 'People'},
                right => {
                    name => 'id',
                   
                },
                operator          => '=',
                condition         => 'AND',
            },
            {
                condition => 'AND',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus',
                                    view => 'People' },
                    right      => {
                        function => 'abs',
                        left     => {
                            expression => '*',
                            left       => {
                                name => 'bonus',
                                view => 'Other'
                            },
                            right => { name => 'bonus', }
                        }
                    }
                },
                right    => { name => 'first_name', },
                operator => '=',
            }
        ],
    }
);
$da->add_sort(
    {
        expression => '+',
        left       => { name => 'salary', },
        right      => {
            expression => '*',
            left       => { name => 'bonus', },
            right      => {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => {
                        name => 'bonus',
                        view => 'Other'
                    },
                    right => { name => 'bonus', }
                }
            }
        }
    }
);

# warn("da=".Dumper($da));
$da->retrieve( Data::Test->new() );
my $dad      = $da->result->error();
my $elements = $dad->elements;


ok( $elements->[0]->view() eq 'People', 'First element inherits view' );
ok( $elements->[1]->view() eq 'other', 'Second element does not inherit view' );
ok(
    $dad->elements->[2]->left->view eq 'People',
    'Third element left inherits view'
);
ok( $dad->elements->[2]->right->left->view eq 'People',
    'Third element right inherits view' );
ok(
    $dad->elements->[3]->left->left->view eq 'Other',
    'Fourth element left does not inherit view'
);
ok(
    $dad->elements->[4]->left->view eq 'People',
    'Fith element left inherits view'
);
ok(
    $dad->elements->[4]->right->left->view eq 'People',
    'Fith element right->left inherits view'
);
ok(
    $dad->elements->[4]->right->right->left->left->view eq 'Other',
    'Fith element right->right->left does not inherit view'
);
ok(
    $dad->elements->[4]->right->right->left->right->view eq 'People',
    'Fith element right->right->left->right inherits view'
);

$elements = $dad->conditions;

ok(
    $elements->[0]->predicates->left->view() eq 'Other',
    'First condition left does not inherit view'
);
ok( $elements->[0]->predicates->right->view() eq 'People',
    'First condition right inherits view' );
ok( $elements->[1]->predicates->left->view() eq 'People',
    'Second condition left inherits view' );

ok(
    $elements->[1]->predicates->right->view() eq 'other',
    'Second condition right does not inherit view'
);

ok(
    $elements->[2]->predicates->left->left->left->view() eq 'Other',
    'Third condition left->left->left does not inherit view'
);

ok( $elements->[2]->predicates->right->view() eq 'People',
    'Third condition right inherits view' );

ok( $elements->[3]->predicates->left->left->view() eq 'People',
    'Fourth condition left->left inherits view' );

ok( $elements->[3]->predicates->right->view() eq 'People',
    'Fourth condition right inherits view' );
ok(
    $elements->[3]->predicates->left->right->left->left->view() eq 'Other',
    'Fourth condition left->right->left->left does not inherit view'
);

ok( $elements->[3]->predicates->left->right->left->right->view() eq 'People',
    'Fourth condition left->right->left->right inherit view' );

$elements = $dad->links;


foreach my $i ( 0 .. 1 ) {
    ok(
        $elements->[$i]->conditions->[0]->predicates->left->view() eq 'People',
        "Link index $i condition left inherit view"
    );
    ok(
        $elements->[$i]->conditions->[0]->predicates->right->view() eq
          'a_country',
        "Link index $i  condition right does not inherit view"
    );
    ok(
        $elements->[$i]->conditions->[1]->predicates->left->left->view() eq
          'People',
        "Link index $i  condition 2 left->left inherits view"
    );
    ok(
        $elements->[$i]->conditions->[1]
          ->predicates->left->right->left->left->view() eq 'Other',
"Link index $i  condition 2 left->right->left->left does not inherit view"
    );
    
   ok(
        $elements->[$i]->conditions->[1]
          ->predicates->left->right->left->right->view() eq 'a_country',
"Link index $i  condition 2 left->right->left->right->left inherits view"
    );
          
    ok(
        $elements->[$i]->conditions->[1]->predicates->condition  eq 'AND',
"Link index $i  condition 2 has AND Contdition"
    );
    ok(
        $elements->[$i]->conditions->[0]->predicates->right->view() eq 'a_country',
        "Link index $i  condition 2 right- inherits view"
    );
    ok(
        $elements->[$i]->conditions->[1]->predicates->right->view() eq 'a_country',
        "Link index $i  condition 2 right- inherits view"
    );
}


$elements = $dad->sorts;

ok( $elements->[0]->view() eq 'People', 'First sort element inherits view' );
ok(
    $elements->[1]->view() eq 'other',
    'Second sort element does not inherit view'
);
ok(
    $dad->elements->[2]->left->view eq 'People',
    'Third sort element left inherits view'
);
ok(
    $elements->[2]->right->left->view eq 'People',
    'Third sort element right inherits view'
);
ok(
    $elements->[3]->left->left->view eq 'Other',
    'Fourth sort element left does not inherit view'
);

foreach my $i ( 4 .. 5 ) {
    ok(
        $elements->[4]->left->view eq 'People',
        "Sort element index $i left inherits view"
    );
    ok(
        $elements->[4]->right->left->view eq 'People',
        "Sort element index $i right->left inherits view"
    );
    ok(
        $elements->[4]->right->right->left->left->view eq 'Other',
        "Sort element index $i right->right->left does not inherit view"
    );
    ok(
        $elements->[4]->right->right->left->right->view eq 'People',
        "Sort element index $i right->right->left->right inherits view"
    );
}

$elements = $dad->gather;
# warn( Dumper($elements) );
ok(
    $elements->elements->[0]->view() eq 'People',
    'First Gather element inherits view'
);
ok(
    $elements->elements->[1]->view() eq 'Other People',
    'Second Gather element does not inherit view'
);
ok(
    $elements->elements->[2]->view() eq 'People',
    'Third Gather element inherits view'
);
ok( $elements->conditions->[0]->predicates->left->view() eq 'People',
    "Gather condition index 0 left inherit view" );
ok(
    $elements->conditions->[1]->predicates->left->view() eq 'Not People',
    "Gather condition index 1 left does not inherit view"
);
ok( $elements->conditions->[2]->predicates->left->left->view() eq 'People',
    "Gather condition index 2 left->left inherits view" );
ok( $elements->conditions->[2]->predicates->left->right->left->left->view() eq 'Other',
    "Gather condition index 2 left->right->left->left does not inherit view" );
ok(
    $elements->conditions->[2]->predicates->left->right->left->right->view() eq
      'People',
    "Gather condition index 2 left->right->left->right does not inherit view"
);
ok(
    $elements->conditions->[2]->predicates->right->view() eq
      'People',
    "Gather condition index 2 right inherits view"
);

 $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => { name => 'People' },
    elements => [
            {
                function => 'substr',
                left     => { name => 'username' },
                right    => [
                    { param => 3 },
                    {
                        function => 'left',
                        left     => { name => 'address' },
                        right    => { param => 4 }
                    }
                ]
            }
        ],
    };

 $da = Database::Accessor->new($in_hash);
 $da->retrieve( Data::Test->new() );
 $dad      = $da->result->error();
 $elements = $dad->elements;
;

 ok(
    $elements->[0]->right->[1]->left->view() eq 'People',
    "function in function inherits view"
)