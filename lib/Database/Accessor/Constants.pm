package Database::Accessor::Constants;
use warnings;
use strict;
BEGIN {
  $Database::Accessor::Constants::VERSION = "0.01";
}
use constant AVG    =>'AVG';
use constant COUNT  =>'COUNT';
use constant MEDIAN =>'MEDIAN';
use constant MAX    =>'MAX';
use constant MIN    =>'MIN';
use constant SUM    =>'SUM';
use constant AGGREGATES =>{
             Database::Accessor::Constants::AVG    =>1,
             Database::Accessor::Constants::COUNT  =>1,
             Database::Accessor::Constants::MEDIAN =>1,
             Database::Accessor::Constants::MAX    =>1,
             Database::Accessor::Constants::MIN    =>1,
             Database::Accessor::Constants::SUM    =>1,};
 1;
