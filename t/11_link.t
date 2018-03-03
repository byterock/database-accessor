#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 5;
use Moose::Util qw(does_role);
BEGIN {
    use_ok('Database::Accessor');
    use_ok('Database::Accessor::Link');
}

my $link = Database::Accessor::Link->new({ type=>'left',
                                           to=>{name=>'test'},
                                           predicates=>[{left=> {name=>'field-1',
                                                             view=>'table-1'},
                                                     right=>{name=>'field-2',
                                                             view=>'table-1'},
                                                     
                                                     operator=>'='}]});

exit;
ok( ref($link) eq 'Database::Accessor::Link', "link is a Link" );

ok( does_role($link,"Database::Accessor::Roles::PredicateArray") eq 1,"link does role Database::Accessor::Roles::PredicateArray");
ok( ref($link->predicates()->[0]) eq 'Database::Accessor::Predicate',"predicated contains a predicate");
ok( $link->predicates()->[0]->operator() eq '=',"predicat->0 has operator '='");

warn(Dumper($link));
ok( $link->view eq 'test',"view is 'test'");
ok( $link->alias eq 'new_test',"alias is 'new_test'");
ok( $link->type eq 'left',"type is 'left'");
1;
