{
package Database::Accessor::Types;
use Moose::Role;

use lib qw(D:\GitHub\database-accessor\lib);
use Moose::Util::TypeConstraints;
use Database::Accessor::View;
use Database::Accessor::Element;
use Database::Accessor::Predicate;

class_type 'View',  { class => 'Database::Accessor::View' };
class_type 'Element',  { class => 'Database::Accessor::Element' };
class_type 'Predicate',  { class => 'Database::Accessor::Predicate' };

subtype 'ArrayRefofElements' => as 'ArrayRef[Element]';
subtype 'ArrayRefofPredicates' => as 'ArrayRef[Predicate]';

coerce 'Element', from 'HashRef', via { Database::Accessor::Element->new( %{$_} ) };
coerce 'View', from 'HashRef', via { Database::Accessor::View->new( %{$_} ) };

coerce 'ArrayRefofElements', from 'ArrayRef', via {
    [ map { Database::Accessor::Element->new($_) } @$_ ];
};

coerce 'ArrayRefofPredicates', from 'ArrayRef', via {
    [ map { Database::Accessor::Predicate->new($_) } @$_ ];
};

1;
}
