package Database::Accessor::Driver::Test;

BEGIN {
    $Database::Accessor::Driver::Test::VERSION = "0.01";
}
use Moose;
with(qw( Database::Accessor::Roles::Driver));

sub execute {
    my $self = shift;
    my ($result, $type, $conn, $container, $opt ) = @_;
    $result->add_param($container);
    $result->effected(10);
    $result->query($type.' Query');
    $result->set([9,8,7,6,5,4,3,2,1,0]);
    $result->DB('Data::Test');
    $result->error($self);  #kludge for testing.  Sends the DAD back to ensure it is correct
    return $result;
}

sub DB_Class {
    my $self = shift;
    return 'Data::Test';
}



1;
