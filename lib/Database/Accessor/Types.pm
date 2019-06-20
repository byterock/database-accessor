use strict;

package Database::Accessor::Types;

# ABSTRACT: A Types Role for Database::Accessor:


use Moose::Role;

# with qw(Database::Accessor::Roles::AllErrors);

use Data::Dumper;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use Database::Accessor::Constants;
use Clone;
use Try::Tiny;


# # use Database::Accessor::View;
# use Database::Accessor::Element;
# use Database::Accessor::Predicate;
# use Database::Accessor::Condition;
# use Database::Accessor::Param;
# use Database::Accessor::Link;
# use Database::Accessor::Function;
# use Database::Accessor::Expression;
# use Database::Accessor::If;
# use Database::Accessor::If::Then;

# Dist::Zilla: +PkgVersion

our $ALL_ERRORS;
our $NEW;

class_type 'If',      { class => 'Database::Accessor::If' };
class_type 'Then',    { class => 'Database::Accessor::If::Then' };
class_type 'View',    { class => 'Database::Accessor::View' };
class_type 'Element', { class => 'Database::Accessor::Element' };

# subtype 'Element'=> as 'Object',
# => where { $_->isa('Database::Accessor::Element') },
# message{"something died there"};

class_type 'Predicate',  { class => 'Database::Accessor::Predicate' };
class_type 'Condition',  { class => 'Database::Accessor::Condition' };
class_type 'Param',      { class => 'Database::Accessor::Param' };
class_type 'Link',       { class => 'Database::Accessor::Link' };
class_type 'Function',   { class => 'Database::Accessor::Function' };
class_type 'Expression', { class => 'Database::Accessor::Expression' };
class_type 'Gather',     { class => 'Database::Accessor::Gather' };

subtype 'ArrayRefofThens' => as 'ArrayRef[Then|ArrayRef]';

# subtype 'ArrayRefofArrayRefofThens' => as 'ArrayRef[If]';

subtype 'ArrayRefofConditions' => as 'ArrayRef[Condition]';

subtype 'LinkArrayRefofConditions' => as 'ArrayRef[Condition]',

  where { scalar( @{$_} ) <= 0 ? 0 : 1; }, message {
    "conditions can not be an empty array ref or undef!";
  };

# subtype 'ArrayRefofElements'   => as
# subtype 'ArrayRefofConditions' => as 'ArrayRef[Condition]';
subtype
  'ArrayRefofElements' => as 'ArrayRef[Element|Param|Function|Expression|If]',
  where { scalar( @{$_} ) <= 0 ? 0 : 1; }, message {
    "ArrayRefofElements can not be an empty array ref";
  };

subtype
  'ArrayRefofGroupElements' => as 'ArrayRef[Element|Function]',
  where { scalar( @{$_} ) <= 0 ? 0 : 1; }, message {
    "ArrayRefofGroupElements can not be an empty array ref";
  };
subtype 'ArrayRefofExpressions' => as
  'ArrayRef[Element|Param|Function|Expression]';

# subtype 'ArrayRefofFunctions' => as
# 'ArrayRef[Element|Param|Function|Expression]';

subtype 'ArrayRefofPredicates' => as 'ArrayRef[Predicate]';
subtype 'ArrayRefofLinks'      => as 'ArrayRef[Link]';
subtype 'ArrayRefofParams'     => as
  'ArrayRef[If|Element|Param|Function|Expression]';

subtype 'NumericOperator', as 'Str', where {
    exists( Database::Accessor::Constants::NUMERIC_OPERATORS->{ uc($_) } );
}, message {
    "The Numeric Operator '"
      . _undef_check($_)
      . "', is not a valid Accessor Numeric Operator!"
      . _try_one_of( Database::Accessor::Constants::NUMERIC_OPERATORS() );
};

subtype 'Operator',
  as 'Str',
  where { exists( Database::Accessor::Constants::OPERATORS->{ uc($_) } ) },
  message {
    "The Operator '"
      . _undef_check($_)
      . "', is not a valid Accessor Operator!"
      . _try_one_of( Database::Accessor::Constants::OPERATORS() );
  };

subtype 'Link',
  as 'Str',
  where { exists( Database::Accessor::Constants::LINKS->{ uc($_) } ) },
  message {
    "The Link '"
      . _undef_check($_)
      . "', is not a valid Accessor Link!"
      . _try_one_of( Database::Accessor::Constants::LINKS() );
  };

coerce 'Gather', from 'HashRef', via {
    die
"Attribute (elements) does not pass the type constraint because: Validation failed for 'ArrayRefofElements' with []"
      if (  exists( $_->{elements} )
        and ref( $_->{elements} ) eq 'ARRAY'
        and scalar( @{ $_->{elements} } == 0 ) );
    my $object = _create_instance( 'Database::Accessor::Gather', $_, 13, $_ );
    return $object;
};

coerce 'Predicate', from 'HashRef', via {

    my $object =
      _create_instance( 'Database::Accessor::Predicate', $_, 13, $_ );
    return $object;
};

sub _create_instance {
    my ( $class, $ops, $caller, $raw ) = @_;
    my $object;
#warn("_create_instance class-$class ".ref( $ops));
    return $ops
      if (ref($ops) eq $class );

    if ($NEW) {
        $object = $class->new( $ops );
    }
    else {
        
        try {
            if ( $class eq 'Database::Accessor::Gather' ) {
                $object = $class->new( %{$ops} );
            }
            else {
                $object = $class->new($ops);
            }
        }
        catch {
            my ( $package1, $filename1, $line1 ) = caller($caller);
            foreach my $error ( $_->errors() ) {
                $ALL_ERRORS->add_error($error);
            }

        };

        if ( ref($ALL_ERRORS) and $ALL_ERRORS->has_errors )
        {   
            my ( $package, $filename, $line, $subroutine ) = caller($caller);
            die _one_error(
                $ALL_ERRORS, $ops,        $subroutine, $package, $filename,
                $line,       $subroutine, $NEW,        $raw
            );
        }
    }
    return $object;

}

sub _is_new {
    my ($new) = @_;
    if ( defined($new) ) {
        $NEW = $new;
    }
    $ALL_ERRORS =
      MooseX::Constructor::AllErrors::Error::Constructor->new( caller => [], );
    return $NEW;

}
coerce 'Element', from 'HashRef', via {
    return _element_coerce($_);
};
coerce 'View', from 'HashRef', via {
    my $object = _create_instance( 'Database::Accessor::View', $_, 13, $_ );
    return $object;
};
coerce 'Param', from 'HashRef', via {
    return _element_coerce($_);
};

coerce 'ArrayRefofLinks', from 'ArrayRef', via {
    return _link_array_or_object($_);
}, from 'HashRef', via {
    return [ Database::Accessor::Link->new($_) ];
};

foreach my $subtypes (qw(LinkArrayRefofConditions ArrayRefofConditions )) {

    coerce $subtypes, from 'ArrayRef', via {

        return _predicate_array_or_object( "Database::Accessor::Condition",
            $_ );
    }, from 'HashRef', via {

        return [ Database::Accessor::Condition->new( { predicates => $_ } ) ];

    };
}

foreach
  my $subtypes (qw(ArrayRefofExpressions ArrayRefofParams ArrayRefofElements))
{

    coerce $subtypes, from 'ArrayRef', via {
        return _right_left_coerce($_);
    };
}
coerce 'ArrayRefofThens', from 'ArrayRef', via {
    return _then_array_or_object($_);
};

coerce 'ArrayRefofPredicates', from 'ArrayRef', via {
    [ map { Database::Accessor::Predicate->new($_) } @$_ ];
};

coerce 'ArrayRefofGroupElements', from 'ArrayRef', via {

    my ($in) = $_;
    my $objects = [];
    foreach my $object ( @{$in} ) {
        if ( ref($object) eq "ARRAY" ) {

            push( @{$objects}, @{$object} );
        }
        else {
            if ( exists( $object->{function} ) ) {
                die
"Attribute (view_elements) does not pass the type constraint because: 
                     Validation failed for 'ArrayRefofGroupElements'. 
                     The Aggrerate '$object->{function}', is not a valid Accessor Aggregate! "
                  . _try_one_of( Database::Accessor::Constants::AGGREGATES() )
                  unless (
                    exists(
                        Database::Accessor::Constants::AGGREGATES->{
                            uc( $object->{function} ) }
                    )
                  );

                $object->{function} = uc( $object->{function} );
                $object = Database::Accessor::Function->new( %{$object} );
            }
            else {
                $object = Database::Accessor::Element->new( %{$object} );

            }
            push( @{$objects}, _element_coerce($object) );
        }
    }
    return $objects;

};

sub _undef_check {
    my ($in) = shift;
    return $in
      if ($in);
    return 'undef';
}

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
#my ($package, $filename, $line) = caller;
#nwarn("_element_coerce $hash, $package, $filename, $line");
    my $class = "Database::Accessor::Element";
    my %copy = ($hash) ? %{ Clone::clone($hash) } : ();
    unless ($hash) {

        my ( $package, $filename, $line, $subroutine ) = caller(4);
        my $add = substr( $subroutine, 4, length($subroutine) );

        $ALL_ERRORS->add_error(
            MooseX::Constructor::AllErrors::Error::Misc->new(
                {
                        message => "Database::Accessor "
                      . $subroutine
                      . " Error:\n"
                      . "You cannot add undef to dynamic_"
                      . $add . "! "
                }
            )
        );
        die _one_error(
            $ALL_ERRORS, $hash,       $subroutine, $package, $filename,
            $line,       $subroutine, $NEW,        $hash
        );
    }
    elsif ( exists( $hash->{expression} ) ) {
        $hash->{expression} = uc( $hash->{expression} );
        $class = "Database::Accessor::Expression";
    }
    elsif ( exists( $hash->{function} ) ) {
        $hash->{function} = uc( $hash->{function} );
        $class = "Database::Accessor::Function";
    }
    elsif ( exists( $hash->{value} ) || exists( $hash->{param} ) ) {
        $class = "Database::Accessor::Param";
    }
    elsif ( exists( $hash->{ifs} ) ) {
        die "Attribute (ifs) does not pass the type constraint because: 
            Validation failed for 'ArrayRefofThens' with less than 2 ifs"
          if (  ref($hash->{ifs})  eq 'ARRAY'
            and scalar( @{ $hash->{ifs} } < 2 ) );
        $class = "Database::Accessor::If";
    }
    else {
        delete( $copy{left} );
        delete( $copy{right} );
    }
#    return $hash
#$      if (ref($hash) eq $class );

    my $object = _create_instance( $class, $hash, 4, \%copy );
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
            my $predicate =
              _create_instance( $class, { predicates => $object }, 4, $object );
            push( @{$objects}, $predicate );
        }
    }
    return $objects;
}

sub _then_array_or_object {

    my ($in) = @_;
    my $objects = [];

    foreach my $object ( @{$in} ) {
        if ( ref($object) eq 'Database::Accessor::If::Then' ) {
            push( @{$objects}, $object );
        }
        elsif ( ref($object) eq "ARRAY" ) {
            my $sub_objects = [];
            foreach my $sub_object ( @{$object} ) {
                push(
                    @{$sub_objects},
                    @{ _then_array_or_object( [$sub_object] ) }
                );
            }
            push( @{$objects}, $sub_objects );
        }
        else {
            push( @{$objects}, Database::Accessor::If::Then->new($object) );
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

            my $instance =
              _create_instance( 'Database::Accessor::Link', $object, 4,
                $object );
            push( @{$objects}, $instance );

        }
    }
    return $objects;
}

sub _one_error {
    my (
        $error_in, $ops,        $call, $package, $filename,
        $line,     $subroutine, $new,  $raw_in
    ) = @_;

    $call =~ s/Database\:\:Accessor\:\://;
    my @errors;
    my $error_msg;
    my $error;
    my $error_package;
    if ( exists( $ENV{'DA_ALL_ERRORS'} ) and $ENV{'DA_ALL_ERRORS'} ) {
        die $error_in;
    }
    else {

        if ( $error_in->missing() ) {
            foreach my $missing ( $error_in->missing() ) {

                $error_package =
                  $missing->attribute->definition_context->{package};
                push( @errors, _get_hint( $missing->attribute ) );
            }

            $error =
                "The following Attribute"
              . _is_are_msg( scalar(@errors) )
              . "required: ("
              . join( ",", @errors ) . ")\n";

        }
        if ( $error_in->invalid() ) {
            @errors = ();
            foreach my $invalid ( $error_in->invalid() ) {
                push(
                    @errors,
                    sprintf(
                        "'%s' Constraint: %s",
                        _get_hint( $invalid->attribute ),
                        $invalid->attribute->type_constraint->get_message(
                            $invalid->data
                        )
                    )
                );
            }

            $error .=
                "The following Attribute"
              . _did_do_msg( scalar(@errors) )
              . " not pass validation: \n"
              . join( "\n", @errors ) . "\n";

        }
        my $on = "";
        if (    ($error_package)
            and ( $error_package eq "Database::Accessor::Element" ) )
        {
            $on = " Possible missing/invalid key in or near:\n"
              . Dumper($raw_in);
        }

        my $misc = "Database::Accessor " . $call . " Error:\n";
        if ( $new != 1 and !defined($raw_in) ) {
            $misc .= "You cannot add 'undef' with " . $call;
        }
        else {

            $misc .=
              $error . $on . "With constructor hash:\n" . Dumper($raw_in);
        }
        my $die =
          MooseX::Constructor::AllErrors::Error::Constructor->new(
            caller => [ $package, $filename, $line, $subroutine ], );
        $die->add_error(
            MooseX::Constructor::AllErrors::Error::Misc->new(
                { message => $misc }
            )
        );
        return $die;
    }
}

sub _is_are_msg {
    my ($count) = @_;
    return "s are "
      if ( $count > 1 );
    return " is ";
}

sub _did_do_msg {
    my ($count) = @_;
    return "s do "
      if ( $count > 1 );
    return " did ";
}

sub _get_hint {
    my ($attribute) = @_;
    my $hint = "";
    if ( $attribute->documentation ) {
        $hint = $attribute->documentation . "->"
          if ( $attribute->documentation ne "None" );

    }
    elsif ( $attribute->definition_context->{package} ) {
        $hint = $attribute->definition_context->{package};
        $hint =~ s/Database\:\:Accessor\:\://;
        $hint =~ s/Roles\:\:Common/new/;
        $hint .= "->";
    }
    return $hint . $attribute->name();
}

1;
