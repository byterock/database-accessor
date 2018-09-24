package Database::Accessor::Driver::Test;
use Data::Dumper;
BEGIN {
    $Database::Accessor::Driver::Test::VERSION = "0.01";
}
use Moose;
with(qw( Database::Accessor::Roles::Driver));

sub execute {
    my $self = shift;
    my ($result, $type, $conn, $container, $opt ) = @_;
    
    $result->processed_container($self->_get_processed_container($container));
    $result->effected(10);
    $result->query($type.' Query');
    $result->set([9,8,7,6,5,4,3,2,1,0]);
    $result->DB('Data::Test');
    $result->error($self);  #kludge for testing.  Sends the DAD back to ensure it is correct
    return $result;
}

sub _get_processed_container {
    my $self = shift;
    my ($in_container) = @_;
    
    my $in_hash_class = 0;
    my @process_array;
    my @return_container;
    if (ref($in_container) eq 'HASH' or blessed($in_container)){
        push(@process_array,$in_container);
        $in_hash_class = 1;
    }
    else {
         push(@process_array,@{$in_container});
    }
    foreach my $record (@process_array){
      my $processed_record = {dad_fiddle=>1};
      foreach my $key (keys(%{$record})){
        $processed_record->{$key} = $record->{$key};
      }
      push(@return_container,$processed_record);
    }
    if ($in_hash_class){
      return shift(@return_container);
    }
    else{
      return \@return_container;
    }
}

sub DB_Class {
    my $self = shift;
    return 'Data::Test';
}



1;
