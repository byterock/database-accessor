
package Database::Accessor::Types2;
use Moose::Role;

use lib qw(D:\GitHub\database-accessor\lib);
use Moose::Util::TypeConstraints;
subtype 'SQLName',
  as 'Str',
  where { if (index($_,' ') == -1 ) {return 1}} ,
  message { "The Name '$_', is not a valid Table, Join or Field name! "};


1;
