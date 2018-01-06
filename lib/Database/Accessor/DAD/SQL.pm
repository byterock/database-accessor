package Database::Accessor::DAD::SQL;

BEGIN {
    $Database::Accessor::DAD::SQL::VERSION = "0.01";
}
use lib qw(D:\GitHub\database-accessor\lib);
use Moose;
with(qw( Database::Accessor::Roles::DAD));

sub Execute {
    my $self = shift;
    my ( $da, $connection, $container, $opts ) = @_;
    my $delimiter = " ";
    my $sql       = "SELECT ";
    foreach my $element ( @{ $self->Elements() } ) {
        $sql .= $delimiter . $self->element_sql($element);

        $delimiter = ", ";

    }
    $sql . " FROM " . $self->element_sql($self->View());
    return $sql . " WHERE "
      if ($self->Conditions());
    foreach my $condtion ($self->Conditions()){
       return $sql . $self->element_sql($condtion->left)
                   . " "
                   .$condtion->operator
                   . " "
                   . $self->element_sql($condtion->right);
    
    }
}

sub DB_Class {
    my $self = shift;
    return 'DBI::db';
}

sub element_sql {
    my $self      = shift;
    my ($element) = @_;
    if ( $element->alias() ) {
        return $element->name() . "  AS " . $element->alias();
    }
    else {
        return $element->name();
    }
}
1;
