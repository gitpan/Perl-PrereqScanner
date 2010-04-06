
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Perl::PrereqScanner',
                       'DISTNAME' => 'Perl-PrereqScanner',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'Jerome Quelin, Ricardo Signes <rjbs@cpan.org>',
                       'BUILD_REQUIRES' => {
                                             'Test::More' => '0',
                                             'Try::Tiny' => '0',
                                             'PPI::Document' => '0',
                                             'File::Temp' => '0'
                                           },
                       'ABSTRACT' => 'a tool to scan your Perl code for its prerequisites',
                       'EXE_FILES' => [
                                        'bin/scan_prereqs'
                                      ],
                       'VERSION' => '0.100960',
                       'PREREQ_PM' => {
                                        'Scalar::Util' => '0',
                                        'List::Util' => '0',
                                        'PPI' => '1.205',
                                        'namespace::autoclean' => '0',
                                        'Version::Requirements' => '0.100630',
                                        'FindBin' => '0',
                                        'File::Spec::Functions' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



