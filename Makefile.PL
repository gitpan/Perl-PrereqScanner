
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Perl::PrereqScanner',
                       'DISTNAME' => 'Perl-PrereqScanner',
                       'AUTHOR' => 'Jerome Quelin',
                       'ABSTRACT' => 'a tool to scan your Perl code for its prerequisites',
                       'EXE_FILES' => [
                                        'bin/scan_prereqs'
                                      ],
                       'VERSION' => '0.100500',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'Try::Tiny' => 0,
                                        'Scalar::Util' => 0,
                                        'PPI' => 0,
                                        'namespace::autoclean' => 0,
                                        'FindBin' => 0,
                                        'ExtUtils::MakeMaker' => '6.11',
                                        'version' => 0,
                                        'Test::More' => 0,
                                        'List::Util' => 0,
                                        'PPI::Document' => 0,
                                        'File::Temp' => 0,
                                        'File::Spec::Functions' => 0
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



