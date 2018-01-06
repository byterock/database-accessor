use strict;
use warnings;
use ExtUtils::MakeMaker 6.30;
my %WriteMakefileArgs = (
  "ABSTRACT" => "",
  "AUTHOR" => "John Scoles <byterock\@hotmail.com>",
  "BUILD_REQUIRES" => {
  
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.38"
  },
  "DISTNAME" => "",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "",
  "PREREQ_PM" => {
   },
  "VERSION" => "0.01",
  "test" => {
    "TESTS" => "t/*.t"
  },
  "META_MERGE" => {
    "resources" => {
      "repository" => '',
      "bugtracker" => '',
      "homepage"   => '',
    },
  },
);
unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}
delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };
WriteMakefile(%WriteMakefileArgs);
