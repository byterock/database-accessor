#!perl 
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;
use lib ('..\t\lib');

use Data::Test;
BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}


  my $in_hash = {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        conditions=>[{ left     =>{ name     =>'user_id',
                                    view     =>'People'},
                       operator => '=',
                       right    =>{ param=>'test'}},
                     { condition=>'AND',
                            left=>{name=>'first_name',
                                   view=>'People'},
                        operator=>'=',
                           right=>{param=>'John'}}, 
                          ]
  };
  
  my $da = Database::Accessor->new($in_hash);
  my $return_str = undef;
  my $data = Data::Test->new();

  my $dad = $da->retrieve($data,$return_str);
  
  ok(ref($dad) eq "Database::Accessor::DAD::Test",'Got the Test DAD');
  
  my $da_conditions  = $da->conditions();
   my $dad_conditions = $dad->Conditions();
   my $in_conditions  = $in_hash->{conditions};
   foreach my $index (0..scalar(@{$in_conditions}-1)) {
      my $in   = $in_conditions->[$index];
      cmp_deeply( $da_conditions->[$index], methods(%{$in})," DA condition attributes correct ");
      cmp_deeply( $dad_conditions->[$index], methods(%{$in})," DAD Condition attributes correct " );
   }

  # warn(ref($da_conditions->[0]));
  # cmp_deeply( $da_conditions->[0], methods(%{$in_hash->{conditions}->[0]}) );
  # cmp_deeply( $da_conditions->[1], methods(%{$in_hash->{conditions}->[1]}) );
  # cmp_deeply( $dad_conditions->[0], methods(%{$in_hash->{conditions}->[0]}) );
  # cmp_deeply( $dad_conditions->[1], methods(%{$in_hash->{conditions}->[1]}) );
  
 # warn(Dumper($da_conditions->[0]));
 #  my $test = 
  
  #
  # 
  
  
  # foreach my $index (0..scalar(@{$in_conditions}-1)) {
      # my $test = $da_conditions->[$index];
      # my $in   = $in_conditions->[$index];
      # ok(ref($test) eq 'Database::Accessor::Condition',"is a Database::Accessor::Condition"));
      # ok(ref($test->left()) eq '',"Left attribute is correct".);
      # ok($test->left() eq $in->{left},"Left attribute is correct");
  # }
  
  # $new_item = {%$new_item}
  
  # foreach my $class ($user,$dad) {  
    # foreach my $attribute (qw(){
       # ucfirst($attribute) 
         # if (ref($class) eq 'Database::Accessor::DAD::Test');
       # ok(ref($class->view) eq 'Database::Accessor::View',"Class ".ref($class). "::view is a View");
    # }
  # }
   