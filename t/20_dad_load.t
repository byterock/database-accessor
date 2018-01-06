#!perl 
use Test::More 0.82;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('..\t\lib');
use strict;
use Test::More tests => 5;

BEGIN {
    use_ok('Database::Accessor');
    use_ok('Data::Test');
}

my $da = Database::Accessor->new();

ok( ref($da) eq 'Database::Accessor', "DA is a Database::Accessor" );
ok($da->_ldad->{'Data::Test'} eq 'Database::Accessor::DAD::Test','Load of DAD Test sucessful');

my $result;
my $fake_data_source = Data::Test->new();

ok($da->retrieve( $fake_data_source, $result ));



