#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib ('t/lib','D:\GitHub\database-accessor\t\lib','D:\GitHub\database-accessor\lib');

use Data::Dumper;
use Data::Test;

use Database::Accessor;
use Test::Database::Accessor::Utils;
use Test::More tests => 9;
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
            right           => { value => 'test->1' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
        },
        {
            condition => 'AND',
            left      => {
                name => 'First_2',
                view => 'People'
            },
            right           => { value => 'test->2' },
            operator        => '=',
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
            right           => { value => 'test->3' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
            condition       => 'AND',
        },
        {
            condition => 'AND',
            left      => {
                name => 'First_2',
                view => 'People'
            },
            right           => { value => 'test->4' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 0
        }
      ]

    ,
};

my $in_hash3 = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
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
    gathers => [
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
    filters => [
        {
            left => {
                name => 'last_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
            condition       => 'AND',
        },
        {
            condition => 'AND',
            left      => {
                name => 'first_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 1
        }
      ]

    ,
};

my $in_hash4 = {
    delete_requires_condition => 0,
    update_requires_condition => 0,
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
    gathers => [
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
    filters => [
        {
            left => {
                name => 'last_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
            condition       => 'AND',
        },
        {
            condition => 'AND',
            left      => {
                name => 'first_name',
                view => 'People'
            },
            right           => { value => 'test' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 0
        }
      ]

    ,
};
my $da     = Database::Accessor->new($in_hash);
my $return = {};
ok($da->retrieve( Data::Test->new(), $return ),"Balanced condition parentheses");

$da     = Database::Accessor->new($in_hash2);

like(
    exception {$da->retrieve( Data::Test->new()) },
    qr /Unbalanced parentheses in your conditions and dynamic_condition/,
    "Caught unbalanced condtion parentheses"
);


$da->add_condition( {
            left => {
                name => 'last_name2',
                view => 'People'
            },
            right           => { value => 'test->5' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 1,
            condition       => 'AND',
        });
ok($da->retrieve( Data::Test->new(), $return ),"Balanced condition parentheses");

$da->add_condition( {
            left => {
                name => 'last_name2',
                view => 'People'
            },
            right           => { value => 'test->6' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
            condition       => 'AND',
        });
like(
    exception {$da->retrieve( Data::Test->new()) },
    qr /Unbalanced parentheses in your conditions and dynamic_condition/,
    "Caught unbalanced condtion parentheses"
);

$da->add_condition( {
            left => {
                name => 'last_name2',
                view => 'People'
            },
            right           => { value => 'test->7' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 1,
        });
$da->retrieve( Data::Test->new(), $return );

warn(Dumper($da->result->error->conditions->[4]->predicates));
ok($da->result->error->conditions->[4]->predicates->[0]->condition() eq 'AND','And added to last condtion predicate');


$da     = Database::Accessor->new($in_hash3);

ok($da->retrieve( Data::Test->new(), $return ),"Balanced filter parentheses");

$da     = Database::Accessor->new($in_hash4);

like(
    exception {$da->retrieve( Data::Test->new()) },
    qr /Unbalanced parentheses in your filters and dynamic_filters/,
    "Caught unbalanced filter parentheses"
);
 
$da->add_filter({left => {
                name => 'last_name',
                view => 'People'
            },
            right           => { value => 'test-8' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 1,
            condition       => 'AND',
        });

ok($da->retrieve( Data::Test->new(), $return ),"Balanced filter parentheses");

$da->add_filter( {
            left => {
                name => 'last_name2',
                view => 'People'
            },
            right           => { value => 'test->9' },
            operator        => '=',
            open_parentheses  => 0,
        });
$da->retrieve( Data::Test->new(), $return );

ok($da->result->error->filters->[3]->predicates->[0]->condition() eq 'AND','And added to last filter predicate');


1;
