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

use Test::More tests => 39;
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
        }
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
            left      => { name => 'First_2', },
            right     => {
                name => 'First_2',
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
            right    => { name => 'First_2', },
            operator => '=',
        },
  
    ],

};

my $da = Database::Accessor->new($in_hash);
$da->add_condition({
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
            right    => { name => 'First_2', },
            operator => '=',
        });
        

    $da->retrieve( Data::Test->new() );
    my $dad = $da->result->error();
    my $elements = $dad->elements;
    ok( $elements->[0]->view() eq 'People', 'First element inherits view' );
    ok(
        $elements->[1]->view() eq 'other',
        'Second element does not inherit view'
    );
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
    warn( Dumper($elements) );

ok(
    $elements->[0]->predicates->left->view() eq 'Other',
    'First condition left does not inherit view'
);
ok(
    $elements->[0]->predicates->right->view() eq 'People',
    'First condition right inherits view'
);
ok(
    $elements->[1]->predicates->left->view() eq 'People',
    'Second condition left inherits view'
);
ok(
    $elements->[1]->predicates->left->view() eq 'other',
    'Second condition right does not inherit view'
);

ok(
    $elements->[2]->predicates->left->left->left->view() eq 'other',
    'Third condition left->left->left does not inherit view'
);

ok(
    $elements->[2]->predicates->right->view() eq 'People',
    'Third condition right inherits view'
);
ok(
    $elements->[3]->predicates->left->left->view() eq 'People',
    'Fourth condition left->left inherits view'
);
ok(
    $elements->[3]->predicates->right->view() eq 'People',
    'Fourth condition right inherits view'
);
ok(
    $elements->[3]->predicates->left->right->left->left->view() eq 'Other',
    'Fourth condition left->right->left->left does not inherit view'
);
ok(
    $elements->[3]->predicates->left->right->left->right->view() eq 'People',
    'Fourth condition left->right->left->right inherit view'
);
