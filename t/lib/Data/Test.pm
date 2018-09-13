#!perl

package Data::Test;
use Moose;

has [
        qw(first_name
           last_name
         )
        ] => (
          is          => 'rw',
          isa         => 'Str',
          default     => 'test'
        ); 

1;
 
