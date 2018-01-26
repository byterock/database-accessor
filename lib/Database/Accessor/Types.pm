{
package Database::Accessor::Types;
use Moose::Role;
use Data::Dumper;
use lib qw(D:\GitHub\database-accessor\lib);
use Moose::Util::TypeConstraints;
use Database::Accessor::Constants;
use Database::Accessor::View;
use Database::Accessor::Element;
use Database::Accessor::Predicate;
use Database::Accessor::Condition;
use Database::Accessor::Param;
use Database::Accessor::Link;

class_type 'View',  { class => 'Database::Accessor::View' };
class_type 'Element',  { class => 'Database::Accessor::Element' };
class_type 'Predicate',  { class => 'Database::Accessor::Predicate' };
class_type 'Condition',  { class => 'Database::Accessor::Condition' };
class_type 'Param',  { class => 'Database::Accessor::Param' };
class_type 'Link',  { class => 'Database::Accessor::Link' };


subtype 'ArrayRefofConditions' =>as 'ArrayRef[Condition]';
subtype 'ArrayRefofElements' => as 'ArrayRef[Element]';
subtype 'ArrayRefofPredicates' => as 'ArrayRef[Predicate]';
subtype 'ArrayRefofLinks' => as 'ArrayRef[Link]';




coerce 'Element', from 'HashRef', via { Database::Accessor::Element->new( %{$_} ) };
coerce 'View', from 'HashRef', via { Database::Accessor::View->new( %{$_} ) };
coerce 'Param', from 'HashRef', via { Database::Accessor::Param->new( %{$_} ) };

coerce 'ArrayRefofLinks', from 'ArrayRef', via {   
     [ map { Database::Accessor::Link->new($_) } @$_ ];
},
    from 'HashRef', via {
    return [Database::Accessor::Link->new($_) ];
};

coerce 'ArrayRefofConditions', from 'ArrayRef', via {
  
    # return [ Database::Accessor::Condition->new({predicates=>[@$_]})];
    my $objects = [];
    foreach my $object (@$_) {
        push( @{$objects}, Database::Accessor::Condition->new({predicates=>[$object]}) ); 
     }
    return $objects  
  },
   from 'HashRef', via {
    my $objects = [];
    push( @{$objects}, Database::Accessor::Condition->new({predicates=>[$_]}) );
    return $objects;
};


coerce 'ArrayRefofElements', from 'ArrayRef', via {
    [ map { Database::Accessor::Element->new($_) } @$_ ];
};

coerce 'ArrayRefofPredicates', from 'ArrayRef', via {
    [ map { Database::Accessor::Predicate->new($_) } @$_ ];
};

subtype 'Expression',
as 'Str',
  where { exists( Database::Accessor::Constants::EXPRESSION->{ uc($_) } ) },
  message { "The Expression '$_', is not a valid Accessor Expression!"._try_one_of(Database::Accessor::Constants::EXPRESSION()) };


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
