#!perl 
use Test::More 0.82;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use Test::More tests => 3;
use lib ('..\t\lib');

use Data::Test;
BEGIN {
    use_ok( 'Database::Accessor' ) || print "Bail out!";
}



my $user = Database::Accessor->new(
    {
        view     => {name  => 'People'},
        elements => [{ name => 'first_name',
                                 view=>'People' },
                             { name => 'last_name',
                                view => 'People' },
                             { name => 'user_id',
                                view =>'People' } ],
        conditions=>[{ left=>{name=>'user_id',
                               view=>'People'},
                               operator=>'=',
                               right=>{param=>'test'}},
                               { condition=>'AND',
                                   left=>{name=>'first_name',
                                             view=>'People'},
                                  operator=>'=',
                                 right=>{param=>'John'}}, 
                                 ]
    }
);

     my $return_str = undef;
     my $data  = Data::Test->new();
     $user->retrieve($data,$return_str);

   ok($return_str eq "RETRIEVE-->View-->'People'-->Elements-->'People.first_name', 'People.last_name','People.user_id'-->Condtion->People.user_id=test-->AND--> People.first_name=John",'Got the correct result');
   