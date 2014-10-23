use 5.008;
package Perl::PrereqScanner;
BEGIN {
  $Perl::PrereqScanner::VERSION = '0.101890';
}
use Moose;
# ABSTRACT: a tool to scan your Perl code for its prerequisites

use List::Util qw(max);
use Params::Util qw(_CLASS);
use Perl::PrereqScanner::Scanner;
use PPI 1.205; # module_version
use String::RewritePrefix 0.005 rewrite => {
  -as => '__rewrite_scanner',
  prefixes => { '' => 'Perl::PrereqScanner::Scanner::', '=' => '' },
};

use Version::Requirements 0.100630; # merge with 0-min bug fixed

use namespace::autoclean;

has scanners => (
  is  => 'ro',
  isa => 'ArrayRef[Perl::PrereqScanner::Scanner]',
  init_arg => undef,
  writer   => '_set_scanners',
);

sub __scanner_from_str {
  my $class = __rewrite_scanner($_[0]);
  confess "illegal class name: $class" unless _CLASS($class);
  eval "require $class; 1" or die $@;
  return $class->new;
}

sub __prepare_scanners {
  my ($self, $specs) = @_;
  my @scanners = map {; ref $_ ? $_ : __scanner_from_str($_) } @$specs;

  return \@scanners;
}

sub BUILD {
  my ($self, $arg) = @_;

  my @scanners = @{ $arg->{scanners} || [ qw(Perl5 Moose) ] };
  my @extra_scanners = @{ $arg->{extra_scanners} || [] };

  my $scanners = $self->__prepare_scanners([ @scanners, @extra_scanners ]);

  $self->_set_scanners($scanners);
}


sub scan_string {
  my ($self, $str) = @_;
  my $ppi = PPI::Document->new( \$str );
  return $self->scan_ppi_document( $ppi );
}



sub scan_file {
  my ($self, $path) = @_;
  my $ppi = PPI::Document->new( $path );
  return $self->scan_ppi_document( $ppi );
}



sub scan_ppi_document {
  my ($self, $ppi_doc) = @_;

  my $req = Version::Requirements->new;

  for my $scanner (@{ $self->{scanners} }) {
    $scanner->scan_for_prereqs($ppi_doc, $req);
  }

  return $req;
}

1;


=pod

=head1 NAME

Perl::PrereqScanner - a tool to scan your Perl code for its prerequisites

=head1 VERSION

version 0.101890

=head1 SYNOPSIS

  use Perl::PrereqScanner;
  my $scanner = Perl::PrereqScanner->new;
  my $prereqs = $scanner->scan_ppi_document( $ppi_doc );
  my $prereqs = $scanner->scan_file( $file_path );
  my $prereqs = $scanner->scan_string( $perl_code );

=head1 DESCRIPTION

The scanner will extract loosely your distribution prerequisites from your
files.

The extraction may not be perfect but tries to do its best. It will currently
find the following prereqs:

=over 4

=item *

plain lines beginning with C<use> or C<require> in your perl modules and scripts, including minimum perl version

=item *

regular inheritance declared with the C<base> and C<parent> pragmata

=item *

L<Moose> inheritance declared with the C<extends> keyword

=item *

L<Moose> roles included with the C<with> keyword

=back

It will trim the following pragamata: C<strict>, C<warnings>, and C<lib>.
C<base> is trimmed unless a specific version is required.  C<parent> is kept,
since it's only recently become a core library.

=head2 Scanner Plugins

Perl::PrereqScanner works by running a series of scanners over a PPI::Document
representing the code to scan.  By default the "Perl5" and "Moose" scanners
are run.  You can supply your own scanners when constructing your
PrereqScanner:

  # Do not use the Moose scanner, only Perl5:
  my $scanner = Perl::PrereqScanner->new({ plugins => [ qw(Perl5) ] });

  # Use any stock plugins, plus Example:
  my $scanner = Perl::PrereqScanner->new({ extra_plugins => [ qw(Example) ] });

=head1 METHODS

=head2 scan_string

  my $prereqs = $scanner->scan_string( $perl_code );

Given a string containing Perl source code, this method returns a
Version::Requirements object describing the modules it requires.

=head2 scan_file

  my $prereqs = $scanner->scan_file( $path );

Given a file path to a Perl document, this method returns a
Version::Requirements object describing the modules it requires.

=head2 scan_ppi_document

  my $prereqs = $scanner->scan_ppi_document( $ppi_doc );

Given a L<PPI::Document>, this method returns a Version::Requirements object
describing the modules it requires.

=for Pod::Coverage::TrustPod new

=head1 AUTHORS

  Jerome Quelin
  Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

