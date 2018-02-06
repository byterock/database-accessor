package Database::Accessor::DAD::Test;

BEGIN {
    $ Database::Accessor::DAD::Test::VERSION = "0.01";
}
use lib qw(D:\GitHub\DA-blog\lib);
use Moose;
with(qw( Database::Accessor::Roles::DAD));

sub Execute {
   my $self = shift;
   my($type, $conn, $container, $opt) = @_;
   
   $container->{dad} = $self;
  
}

sub DB_Class {
    my $self = shift;
    return 'Data::Test';
}


1;
