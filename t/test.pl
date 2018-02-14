#!perl 
use strict;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use Data::Dumper;
# use Database::Accessor;
use Data::Test;
use Carp;
my $in_hash = {
        view => {name=>undef,
                 alias=>undef},
  
    };
# my $da;
  # #eval {
      # $da = Database::Accessor->new({view=>{name=>'test'}});
  # # };
   # # foreach my $error ($@->errors){
   # # print "da=".Dumper($error);
# # }
   # my $return = {};
   # $da->retrieve(Data::Test->new(),$return); 
   # my $dad = $return->{dad};
   
   
   # $da->{view}=["stus",'stuff2'];
  # warn(Dumper($da));
   # # print "da=".Dumper($da);
   
{

    package Database::Accessor::Base;
    
    use Moose;
    # with qw(Database::Accessor::Types
            # );
    # use MooseX::Constructor::AllErrors;
    
    1;

}
{

    package Database::Accessor::View;
    use Moose;
    extends 'Database::Accessor::Base';
    #with qw(Database::Accessor::Roles::Alias);
    
  # 
    
    #use MooseX::Constructor::AllErrors;
   # has '+name' => ( required => 1 );
   1;
}