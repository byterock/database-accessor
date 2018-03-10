#!perl
use strict;
use warnings;
use lib ('t/lib');
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;

use Test::More tests => 10;


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
            open_parenthes  => 1,
            close_parenthes => 0,
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
            open_parenthes  => 0,
            close_parenthes => 1
        }
      ]

    ,
};

my $da     = Database::Accessor->new($in_hash);
my $return = {};
$da->retrieve( Data::Test->new(), $return );
my $dad = $return->{dad};

Test::Database::Accessor::Utils::deep_element( $in_hash->{gathers},
    $da->gathers, $dad->gathers, 'Gather' );
Test::Database::Accessor::Utils::deep_predicate( $in_hash->{filters},
    $da->filters(), $dad->filters(), 'Filters' );

# $da = Database::Accessor->new({view     => {name  => 'People'}});

# $in_hash = {
# gathers => [{ name => 'first_name',
# view=>'People' },
# { name => 'last_name',
# view => 'People' },
# { name => 'user_id',
# view =>'People' } ],

# };

# foreach my $gather (@{$in_hash->{gathers}}){
# ok($da->add_gather($gather),"can add an single Dynamic gather");
# }

# my $dad = $da->retrieve(Data::Test->new());

# Test::Database::Accessor::Utils::deep_element($in_hash->{gathers},$da->dynamic_gathers,$dad->gathers,'Dynamic Gather');

# $da = Database::Accessor->new({view     => {name  => 'People'}});

# ok($da->add_gather($in_hash->{gathers}),"can add an array of Dynamic gathers");

# $in_hash = {filters=>[{left           =>{name =>'last_name',
# view =>'People'},
# right          =>{value=>'test'},
# operator       =>'=',
# open_parenthes =>1,
# close_parenthes=>0,
# condition      =>'AND',
# },
# {condition      =>'AND',
# left           =>{name=>'first_name',
# view=>'People'},
# right          =>{ value=>'test'},
# operator       =>'=',
# open_parenthes =>0,
# close_parenthes=>1
# }
# ]
# };

# $da = Database::Accessor->new({view     => {name  => 'People'}});

# foreach my $filter (@{$in_hash->{filters}}){
# ok($da->add_filter($filter),"can add an single Dynamic filter");
# }

# my $dad = $da->retrieve(Data::Test->new());
# Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->filters(),'dynamic filters');

# $da = Database::Accessor->new({view     => {name  => 'People'}});

# ok($da->add_filter($in_hash->{filters}),"can add an array ref of Dynamic filters");

# my $dad = $da->retrieve(Data::Test->new());
# Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->filters(),'array ref of dynamic filters');

# $da = Database::Accessor->new({view     => {name  => 'People'}});

# ok($da->add_filter(@{$in_hash->{filters}}),"can add an array of Dynamic filters");

# my $dad = $da->retrieve(Data::Test->new());
# Test::Database::Accessor::Utils::deep_predicate($in_hash->{filters},$da->dynamic_filters(),$dad->filters(),'Array of dynamic filters');

# # warn("da=".Dumper($da));
1;
