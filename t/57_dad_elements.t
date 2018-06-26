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
    $elements->[0]->predicates->[0]->left->view() eq 'Other',
    'First condtion left does not inherit view'
);
ok(
    $elements->[0]->predicates->[0]->right->view() eq 'People',
    'First condtion right inherits view'
);
ok(
    $elements->[1]->predicates->[0]->left->view() eq 'People',
    'Second condtion left inherits view'
);
ok(
    $elements->[1]->predicates->[0]->left->view() eq 'other',
    'Second condtion right does not inherit view'
);

ok(
    $elements->[2]->predicates->[0]->left->left->left->view() eq 'other',
    'Third condtion left->left->left does not inherit view'
);

ok(
    $elements->[2]->predicates->[0]->right->view() eq 'People',
    'Third condtion right inherits view'
);
ok(
    $elements->[3]->predicates->[0]->left->left->view() eq 'People',
    'Fourth condtion left->left inherits view'
);
ok(
    $elements->[3]->predicates->[0]->right->view() eq 'People',
    'Fourth condtion right inherits view'
);
ok(
    $elements->[3]->predicates->[0]->left->right->left->left->view() eq 'Other',
    'Fourth condtion left->right->left->left does not inherit view'
);
ok(
    $elements->[3]->predicates->[0]->left->right->left->right->view() eq 'People',
    'Fourth condtion left->right->left->right inherit view'
);
