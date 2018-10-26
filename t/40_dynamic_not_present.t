#!perl
use strict;
use warnings;
use lib ('t/lib');
use lib (
    't/lib',
    'D:\GitHub\database-accessor\t\lib',
    'D:\GitHub\database-accessor\lib'
);
use Data::Dumper;
use Data::Test;
use Database::Accessor;
use Test::Database::Accessor::Utils;
use Test::Deep;
use Test::Fatal;
use Test::More tests => 4;


my $in_hash = {
    view => { name => 'People' },
    elements => [ { name => 'first_name', }, 
                  { name => 'last_name', }, ]
};

my $params = {
    gather => {
        action    =>'gather',
        caption   => 'view_elements',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query => {
            elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'last_name',
                    view => 'People'
                }
            ],
            view_elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'salary',
                    view => 'People'
                }
            ],
        }
    },
    gather2 => {
        action    =>'gather',
        caption   => 'elements',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query => {
            elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'salary',
                    view => 'People'
                }
            ],
            view_elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'last_name',
                    view => 'People'
                }
            ],
        }
    },
    gather3 => {
        action    =>'gather',
        caption   => 'conditions',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query => {
            elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'last_name',
                    view => 'People'
                }
            ],
            view_elements => [
                {
                    name => 'first_name',
                    view => 'People'
                },
                {
                    name => 'last_name',
                    view => 'People'
                }
            ],
            conditions=>[{
                left => {
                    name => 'salary',
                },
                right    => { value => '5' },
                operator => '>',
            },],
        }
    },
    sort => {
        action    => 'sort',
        caption   => 'sort',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query =>{
               name        =>'salary',
               view       =>'People',
               descending => 1}
    },
    condition => {
        action    =>'condition',
        caption   => 'condition',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query =>{
                condition => 'AND',
                left   => { name => 'salary' },
                right  => { value => '5' },
                operator  => '>',
            }
    },
    link => {
        action    =>'link',
        caption   => 'link',
        exception =>
"in not in the elements array! Only elements from that array can be added",
        query =>{
                type       => 'right',
                to         => { name => 'People',
                                alias   => 'p2' },
                conditions => [
                    {
                        left  => { name => 'id',
                                   view => 'p2' },
                        right => {
                            name => 'id',
                            view => 'People'
                        }
                    },
                   {
                        left  => { name => 'salary',
                                   view =>'p2' },
                        right => {
                            value => '5',
                        },
                       operator=>">",
                       condition=>'AND'
                    }
                ]
            }
    },
};

foreach my $in_action (sort(keys(%{$params}))) {
    
        my $action    =  $params->{$in_action}->{action};
    my $da        = Database::Accessor->new($in_hash);
    my $command   = "add_" . $action;
    my $exception = $params->{$in_action}->{exception};
    like(
        exception { $da->$command( $params->{$in_action}->{query} ) },
         qr /$exception/,
"methos add_$action attribute->".$params->{$in_action}->{caption}." is only allowed to have elements that are in the elements attribute"
    );
}
