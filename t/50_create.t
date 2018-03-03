#!perl
use Test::More 0.82;
use Test::Fatal;
use Data::Dumper;
use Test::Deep;
use Test::More tests => 6;
use lib ('..\t\lib');
use Test::Database::Accessor::Utils;
use Data::Test;
use Database::Accessor::Constants;

BEGIN {
    use_ok('Database::Accessor') || print "Bail out!";

}

my $in_hash = {
    view     => { name => 'People' },
    elements => [
        {
            name => 'first_name',
            view => 'People'
        },
        {
            name => 'last_name',
            view => 'People'
        },
        {
            name => 'user_id',
            view => 'People'
        }
    ],
};

my $da = Database::Accessor->new($in_hash);

my $return_str = {};
my $data       = Data::Test->new();

my $dad = $da->create( $data, $return_str );

ok( $return_str->{type} eq Database::Accessor::Constants::CREATE )
