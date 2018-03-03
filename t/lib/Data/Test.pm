#!perl

package Data::Test;
use strict;

 sub new {
    my $class = shift;

    my $self = {};
    bless( $self, ( ref($class) || $class ) );

    return( $self );

}
 
1;
