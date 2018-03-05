#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::More tests => 17;
use Moose::Util qw(does_role);

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Predicate');
}

my $predicate = Database::Accessor::Predicate->new(
    { left => { name => 'left' }, right => { name => 'right' } } );

ok( ref($predicate) eq 'Database::Accessor::Predicate',
    "predicate is a Predicate" );
ok(
    does_role( $predicate, "Database::Accessor::Roles::Comparators" ) eq 1,
    "predicate does role Database::Accessor::Roles::Comparators"
);


like(
  exception { $predicate->alias() },
  qr/locate object method "alias"/,
  "Can not do an alias method",
);


my $function_1_param = {
    left  => { name => 'left' },
    right => {
        function => 'substr',
        left     => { name => 'test' },
        right    => { param => 3 },
    }
};
eval { $predicate = Database::Accessor::Predicate->new($function_1_param); };

if ($@) {

    fail("Function with 1 param works");
}
else {
    pass("Function with 1 param works");
}

ok( ref( $predicate->right ) eq 'Database::Accessor::Function',
    'right is a function' );

my $function_multi_param = {
    left  => { name => 'left' },
    right => {
        function => 'substr',
        left     => { name => 'test' },
        right    => [ { param => 3 }, { param => 2 } ],
    }
};

#eval {
$predicate = Database::Accessor::Predicate->new($function_multi_param);

#};

if ($@) {

    fail("Function with multi params works");
}
else {
    pass("Function with multi params works");
}

my $function_mixed_right = {
    left  => { name => 'left' },
    right => {
        function => 'substr',
        left     => { name => 'test_left' },
        right    => [
            {
                name => 'right_1',
                view => 'table1'
            },
            { param => "right_2" }
        ],
    }
};

eval { $predicate = Database::Accessor::Predicate->new($function_mixed_right); };

if ($@) {

    fail("Function with mixed params works");
}
else {
    pass("Function with mixed params works");
}

ok( ref( $predicate->right()->right->[0] ) eq 'Database::Accessor::Element',
    "My frist right is an Element" );
ok( ref( $predicate->right()->right->[1] ) eq 'Database::Accessor::Param',
    "My second right is a Param" );

my $expression_1_param = {
    left  => { name => 'left' },
    right => {
        expression => '+',
        left       => { name => 'test' },
        right      => { param => 3 },
    }
};
eval { $predicate = Database::Accessor::Predicate->new($expression_1_param); };

if ($@) {

    fail("expression with 1 param works");
}
else {
    pass("expression with 1 param works");
}

ok( ref( $predicate->right ) eq 'Database::Accessor::Expression',
    'right is a expression' );

my $expression_multi_param = {
    left  => { name => 'left' },
    right => {
        expression => '-',
        left       => { name => 'test' },
        right      => [ { param => 3 }, { param => 2 } ],
    }
};
eval {
    $predicate = Database::Accessor::Predicate->new($expression_multi_param);

};

if ($@) {

    fail("Function with multi params works");
}
else {
    pass("Function with multi params works");
}

my $expression_mixed_right = {
    left  => { name => 'left' },
    right => {
        expression => '/',
        left       => { name => 'test_left' },
        right      => [
            {
                name => 'right_1',
                view => 'table1'
            },
            { param => "right_2" }
        ],
    }
};

eval {
    $predicate = Database::Accessor::Predicate->new($expression_mixed_right);
};

if ($@) {

    fail("Function with mixed params works");
}
else {
    pass("Function with mixed params works");
}

ok( ref( $predicate->right()->right->[0] ) eq 'Database::Accessor::Element',
    "My frist right is an Element" );
ok( ref( $predicate->right()->right->[1] ) eq 'Database::Accessor::Param',
    "My second right is a Param" );

# warn(Dumper($predicate));
