

#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);;
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use MooseX::Test::Role;
use Test::More tests => 3;

my @vars = qw(da_warning da_no_effect da_compose_only);


foreach my $var (@vars){   $ENV{$var} = 1;}
my $da = Database::Accessor->new( { retrieve_only => 1, view => { name => 'test' },elements => [ { name => 'first_name', }, { name => 'last_name', }, ]  } );

foreach my $var (@vars) {
   ok($da->$var,"$var set via Env var");}
