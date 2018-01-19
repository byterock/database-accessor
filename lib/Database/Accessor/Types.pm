{
package Database::Accessor::Types;
use Moose::Role;

use lib qw(D:\GitHub\database-accessor\lib);
use Moose::Util::TypeConstraints;
use Database::Accessor::Constants;
use Database::Accessor::View;
use Database::Accessor::Element;
use Database::Accessor::Predicate;
use Database::Accessor::Condition;

class_type 'View',  { class => 'Database::Accessor::View' };
class_type 'Element',  { class => 'Database::Accessor::Element' };
class_type 'Predicate',  { class => 'Database::Accessor::Predicate' };
class_type 'Condition',  { class => 'Database::Accessor::Condition' };


subtype 'ArrayRefofConditions' =>as 'ArrayRef[Condition]';
subtype 'ArrayRefofElements' => as 'ArrayRef[Element]';
subtype 'ArrayRefofPredicates' => as 'ArrayRef[Predicate]';

coerce 'Element', from 'HashRef', via { Database::Accessor::Element->new( %{$_} ) };
coerce 'View', from 'HashRef', via { Database::Accessor::View->new( %{$_} ) };

coerce 'ArrayRefofConditions', from 'ArrayRef', via {
    [ map { Database::Accessor::Condition->new($_) } @$_ ];
};

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

subtype 'Link',
  as 'Str',
  where { exists( Database::Accessor::Constants::LINKS->{ uc($_) } ) },
  message { "The Link '$_', is not a valid Accessor Link!"._try_one_of(Database::Accessor::Constants::LINKS()) };

subtype 'Order',
  as 'Str',
  where { exists( Database::Accessor::Constants::ORDERS->{ uc($_) } ) },
  message { "The Order '$_', is not a valid Accessor Order!"._try_one_of(Database::Accessor::Constants::ORDERS()) };


sub _try_one_of {
    my ($hash) = @_;
    return " Try one of '".join("', '",sort(keys(%{$hash})))."'";     
}
1;

}
