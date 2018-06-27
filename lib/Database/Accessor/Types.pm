use strict;

package Database::Accessor::Types;

# ABSTRACT: A Types Role for Database::Accessor:
use Moose::Role;

# Dist::Zilla: +PkgVersion
#use lib 'D:\GitHub\database-accessor\lib';
use Data::Dumper;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use Database::Accessor::Constants;
use Database::Accessor::View;
use Database::Accessor::Element;
use Database::Accessor::Predicate;
use Database::Accessor::Condition;
use Database::Accessor::Param;
use Database::Accessor::Link;
use Database::Accessor::Function;
use Database::Accessor::Expression;

class_type 'View',       { class => 'Database::Accessor::View' };
class_type 'Element',    { class => 'Database::Accessor::Element' };
class_type 'Predicate',  { class => 'Database::Accessor::Predicate' };
class_type 'Condition',  { class => 'Database::Accessor::Condition' };
class_type 'Param',      { class => 'Database::Accessor::Param' };
class_type 'Link',       { class => 'Database::Accessor::Link' };
class_type 'Function',   { class => 'Database::Accessor::Function' };
class_type 'Expression', { class => 'Database::Accessor::Expression' };
class_type 'Gather',     { class => 'Database::Accessor::Gather' };

subtype 'ArrayRefofConditions' => as 'ArrayRef[Condition]';
subtype 'ArrayRefofElements'   => as
  'ArrayRef[Element|Param|Function|Expression]';
subtype 'ArrayRefofExpressions' => as
  'ArrayRef[Element|Param|Function|Expression]';
subtype 'ArrayRefofFunctions' => as
  'ArrayRef[Element|Param|Function|Expression]';

subtype 'ArrayRefofPredicates' => as 'ArrayRef[Predicate]';
subtype 'ArrayRefofLinks'      => as 'ArrayRef[Link]';
subtype 'ArrayRefofParams' => as 'ArrayRef[Element|Param|Function|Expression]';
subtype 'NumericOperator', as 'Str', where {
    exists( Database::Accessor::Constants::NUMERIC_OPERATORS->{ uc($_) } );
}, message {
    "The Numeric Operator '$_', is not a valid Accessor Numeric Operato!"
      . _try_one_of( Database::Accessor::Constants::NUMERIC_OPERATORS() );
};

subtype 'Aggregate',
  as 'Str',
  where { exists( Database::Accessor::Constants::AGGREGATES->{ uc($_) } ) },
  message {
    "The Aggrerate '$_', is not a valid Accessor Aggregate!"
      . _try_one_of( Database::Accessor::Constants::AGGREGATES() );
  };

subtype 'Operator',
  as 'Str',
  where { exists( Database::Accessor::Constants::OPERATORS->{ uc($_) } ) },
  message {
    "The Operator '$_', is not a valid Accessor Operator!"
      . _try_one_of( Database::Accessor::Constants::OPERATORS() );
  };

subtype 'Link',
  as 'Str',
  where { exists( Database::Accessor::Constants::LINKS->{ uc($_) } ) },
  message {
    "The Link '$_', is not a valid Accessor Link!"
      . _try_one_of( Database::Accessor::Constants::LINKS() );
  };

subtype 'Order',
  as 'Str',
  where { exists( Database::Accessor::Constants::ORDERS->{ uc($_) } ) },
  message {
    "The Order '$_', is not a valid Accessor Order!"
      . _try_one_of( Database::Accessor::Constants::ORDERS() );
  };

coerce 'Gather', from 'HashRef', via { Database::Accessor::Gather->new( %{$_} ) };
coerce 'Predicate', from 'HashRef', via { Database::Accessor::Predicate->new( %{$_} ) };
coerce 'Element', from 'HashRef', via {
    return _element_coerce($_);
};
coerce 'View',  from 'HashRef', via { Database::Accessor::View->new( %{$_} ) };
coerce 'Param', from 'HashRef', via { 
    return  _element_coerce($_);
};

coerce 'ArrayRefofLinks', from 'ArrayRef', via {
    return _link_array_or_object($_);
}, from 'HashRef', via {
    return [ Database::Accessor::Link->new($_) ];
};

coerce 'ArrayRefofConditions', from 'ArrayRef', via {
    

    return _predicate_array_or_object( "Database::Accessor::Condition", $_ );
}, from 'HashRef', via {
       
    return [ Database::Accessor::Condition->new( { predicates => $_ } ) ];

};



coerce 'ArrayRefofParams', from 'ArrayRef', via {
   _right_left_coerce($_);
};

coerce 'ArrayRefofElements', from 'ArrayRef', via {

    _right_left_coerce($_);
};

coerce 'ArrayRefofExpressions', from 'ArrayRef', via {

    _right_left_coerce($_);
};
coerce 'ArrayRefofFunctions', from 'ArrayRef', via {

    _right_left_coerce($_);
};

coerce 'ArrayRefofPredicates', from 'ArrayRef', via {

    [ map { Database::Accessor::Predicate->new($_) } @$_ ];
};

sub _right_left_coerce {
    my ($in) = @_;
    
   
    my $objects = [];
    foreach my $object ( @{$in} ) {
        if ( ref($object) eq "ARRAY" ) {
            push( @{$objects}, @{$object} );
        }
        else {
            push( @{$objects}, _element_coerce($object) );
        }
    }
    return $objects;
}

sub _element_coerce {
    my ($hash) = @_;
    my $object;
    if ( exists( $hash->{expression} ) ) {
        $object = Database::Accessor::Expression->new( %{$hash} );
    }
    elsif ( exists( $hash->{function} ) ) {
        $object = Database::Accessor::Function->new( %{$hash} );
    }
    elsif ( exists( $hash->{value} ) || exists( $hash->{param} ) ) {
        $object = Database::Accessor::Param->new( %{$hash} );
    }
    else {
        $object = Database::Accessor::Element->new( %{$hash} );

    }
    return $object;
}

sub _try_one_of {
    my ($hash) = @_;
    return " Try one of '" . join( "', '", sort( keys( %{$hash} ) ) ) . "'";
}

sub _predicate_array_or_object {

    my ( $class, $in ) = @_;
    my $objects = [];
    foreach my $object ( @{$in} ) {

        if ( ref($object) eq $class ) {
            push( @{$objects}, $object );
        }
        elsif ( ref($object) eq "ARRAY" ) {
            push(
                @{$objects},
                @{ _predicate_array_or_object( $class, $object ) }
            );
        }
        else {
            push( @{$objects}, $class->new( { predicates => $object } ) );
        }
    }
    return $objects;

}

sub _link_array_or_object {
    my ($in) = @_;

    my $objects = [];
    foreach my $object ( @{$in} ) {
        if ( ref($object) eq 'Database::Accessor::Link' ) {
            push( @{$objects}, $object );
        }
        elsif ( ref($object) eq "ARRAY" ) {

            push( @{$objects}, @{ _link_array_or_object($object) } );
        }
        else {
            push( @{$objects}, Database::Accessor::Link->new($object) );
        }
    }
    return $objects;
}

1;
