{
package Database::Accessor::Types;
use Moose::Role;

use lib qw(D:\GitHub\database-accessor\lib);
use Moose::Util::TypeConstraints;
use Database::Accessor::Constants;
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

subtype 'Aggregate',
  as 'Str',
  where { exists( Database::Accessor::Constants::AGGREGATES->{ uc($_) } ) },
  message { "The Aggrerate '$_', is not a valid Accessor Aggregate!"._try_one_of(Database::Accessor::Constants::AGGREGATES()) };

subtype 'Operator',
  as 'Str',
  where { exists( Database::Accessor::Constants::OPERATORS->{ uc($_) } ) },
  message { "The Operator '$_', is not a valid Accessor Operator!"._try_one_of(Database::Accessor::Constants::OPERATORS()) };


sub _try_one_of {
    my ($hash) = @_;
    return " Try one of '".join("', '",sort(keys(%{$hash})))."'";     
}
1;

}
