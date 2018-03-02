use strict;
package Database::Accessor::Constants;
# Dist::Zilla: +PkgVersion

# ABSTRACT: Constants for  DaCRUD Interface for any DB
use warnings;
use constant AVG    =>'AVG';
use constant COUNT  =>'COUNT';
use constant MEDIAN =>'MEDIAN';
use constant MAX    =>'MAX';
use constant MIN    =>'MIN';
use constant SUM    =>'SUM';
use constant IN                =>'IN';
use constant NOT_IN            =>'NOT IN';
use constant BETWEEN           =>'BETWEEN';
use constant LIKE              =>'LIKE';
use constant IS_NULL           =>'IS NULL';
use constant NULL              =>'NULL';
use constant IS_NOT_NULL       =>'IS NOT NULL';
use constant AND               =>'AND';
use constant OR                =>'OR';
use constant OUTER    =>'OUTER';
use constant LEFT     =>'LEFT';
use constant RIGHT    =>'RIGHT';
use constant CREATE   =>'CREATE';
use constant RETRIEVE =>'RETRIEVE';
use constant UPDATE   =>'UPDATE';
use constant DELETE   =>'DELETE';

use constant LINKS =>{
    Database::Accessor::Constants::OUTER =>1,
    Database::Accessor::Constants::LEFT  =>1,
    Database::Accessor::Constants::RIGHT =>1,
};

use constant AGGREGATES =>{
             Database::Accessor::Constants::AVG    =>1,
             Database::Accessor::Constants::COUNT  =>1,
             Database::Accessor::Constants::MEDIAN =>1,
             Database::Accessor::Constants::MAX    =>1,
             Database::Accessor::Constants::MIN    =>1,
             Database::Accessor::Constants::SUM    =>1,};



use constant OPERATORS => {
    Database::Accessor::Constants::IN          => 1,
    Database::Accessor::Constants::NOT_IN      => 1,
    Database::Accessor::Constants::BETWEEN     => 1,
    Database::Accessor::Constants::LIKE        => 1,
    Database::Accessor::Constants::IS_NULL     => 1,
    Database::Accessor::Constants::IS_NOT_NULL => 1,
    Database::Accessor::Constants::AND         => 1,
    Database::Accessor::Constants::OR          => 1,
    '=' => 1,
   '!='=> 1,
   '<>'=> 1,
   '>' => 1,
   '>='=> 1,
   '<' => 1,
   '<='=> 1,
};

use constant NUMERIC_OPERATORS => {
   '=' => 1,
   '!='=> 1,
   '<>'=> 1,
   '>' => 1,
   '>='=> 1,
   '<' => 1,
   '<='=> 1,
   '-' => 1,
   '*' => 1,
   '/' => 1,
   '+'=> 1,
};
use constant ASC      =>'ASC';
use constant DESC     =>'DESC';
use constant ORDERS => {
    Database::Accessor::Constants::ASC  => 1,
    Database::Accessor::Constants::DESC => 1,
};
 1;
