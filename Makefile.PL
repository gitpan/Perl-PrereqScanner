
use strict;
use warnings;

BEGIN { require 5.008; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'a tool to scan your Perl code for its prerequisites',
  'AUTHOR' => 'Jerome Quelin, Ricardo Signes <rjbs@cpan.org>',
  'BUILD_REQUIRES' => {
    'File::Temp' => '0',
    'PPI::Document' => '0',
    'Test::More' => '0.96',
    'Try::Tiny' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Perl-PrereqScanner',
  'EXE_FILES' => [
    'bin/scan_prereqs'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'Perl::PrereqScanner',
  'PREREQ_PM' => {
    'File::Spec::Functions' => '0',
    'FindBin' => '0',
    'List::MoreUtils' => '0',
    'List::Util' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'PPI' => '1.205',
    'Params::Util' => '0',
    'String::RewritePrefix' => '0.005',
    'Version::Requirements' => '0.100630',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '1.000',
  'test' => {
    'TESTS' => 't/*.t'
  }
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



