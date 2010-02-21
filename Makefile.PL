
use strict;
use warnings;

 BEGIN { require 5.010; } 

use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Perl::PrereqScanner',
                       'DISTNAME' => 'Perl-PrereqScanner',
                       'AUTHOR' => 'Jerome Quelin, Ricardo Signes <rjbs@cpan.org>',
                       'ABSTRACT' => 'a tool to scan your Perl code for its prerequisites',
                       'EXE_FILES' => [
                                        'bin/scan_prereqs'
                                      ],
                       'VERSION' => '0.100520',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'Try::Tiny' => 0,
                                        'Scalar::Util' => 0,
                                        'PPI' => 0,
                                        'namespace::autoclean' => 0,
                                        'FindBin' => 0,
                                        'ExtUtils::MakeMaker' => '6.11',
                                        'List::Util' => 0,
                                        'Test::More' => 0,
                                        'Version::Requirements' => 0,
                                        'PPI::Document' => 0,
                                        'File::Temp' => 0,
                                        'File::Spec::Functions' => 0
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



