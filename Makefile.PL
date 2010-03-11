
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Perl::PrereqScanner',
                       'DISTNAME' => 'Perl-PrereqScanner',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'Jerome Quelin, Ricardo Signes <rjbs@cpan.org>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'a tool to scan your Perl code for its prerequisites',
                       'EXE_FILES' => [
                                        'bin/scan_prereqs'
                                      ],
                       'VERSION' => '0.100690',
                       'PREREQ_PM' => {
                                        'Scalar::Util' => '0',
                                        'PPI' => '1.205',
                                        'Try::Tiny' => '0',
                                        'namespace::autoclean' => '0',
                                        'FindBin' => '0',
                                        'Test::More' => '0',
                                        'List::Util' => '0',
                                        'Version::Requirements' => '0.100630',
                                        'PPI::Document' => '0',
                                        'File::Temp' => '0',
                                        'File::Spec::Functions' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



