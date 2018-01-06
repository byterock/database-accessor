package Database::Accessor::DAD::Mongo;

BEGIN {
    $Database::Accessor::DAD::Mongo::VERSION = "0.01";
}
use lib qw(D:\GitHub\database-accessor\lib);
use Moose;
with (qw( Database::Accessor::Roles::DAD));


sub Execute {
    my $self = shift;
    my ( $da,$connection, $container, $opts ) = @_;
    my $delimiter = " ";
    my $sql       = "db.";

    $sql .= $self->View()->name();
    $sql .= ".find({},{";

    foreach my $element ( @{ $self->Elements() } ) {

        $sql .= $delimiter . $element->name() . ": 1";
        $delimiter = ", ";

    }
    $sql .= "}";

    return $sql;

}

sub DB_Class {
    my $self = shift;
    return 'MongoDB::Collection';
}


1;
