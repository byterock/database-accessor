package Database::Accessor::Driver::Test;

BEGIN {
    $Database::Accessor::Driver::Test::VERSION = "0.01";
}
use Moose;
with(qw( Database::Accessor::Roles::Driver));

sub execute {
    my $self = shift;
    my ( $type, $conn, $container, $opt ) = @_;

    $container->{dad}  = $self;
    $container->{type} = $type;

}

sub DB_Class {
    my $self = shift;
    return 'Data::Test';
}

sub raw_query {
    my $self = shift;
    my ($conn, $type) = @_;
    return {DAD=>ref($self),
            query=>$type.' query',
        };
}

1;
