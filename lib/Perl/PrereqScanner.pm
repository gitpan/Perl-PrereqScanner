use 5.010;
use strict;
use warnings;

package Perl::PrereqScanner;
our $VERSION = '0.100491';
# ABSTRACT: a tool to scan your Perl code for its prerequisites


use PPI;
use List::Util qw(max);
use Scalar::Util qw(blessed);
use version;

use namespace::autoclean;

sub _q_contents {
  my ($self, $token) = @_;
  my @contents = $token->isa('PPI::Token::QuoteLike::Words')
    ? ( $token->literal )
    : ( $token->string  );

  return @contents;
}

sub new {
  my ($class) = @_;
  bless {} => $class;
}

sub _add_prereq {
  my ($self, $prereq, $name, $newver) = @_;

  $newver = version->parse($newver) unless blessed($newver);

  if (defined (my $oldver = $prereq->{ $name })) {
    if (defined $newver) {
      $prereq->{ $name } = (sort { $b cmp $a } ($newver, $oldver))[0];
    }
    return;
  }

  $prereq->{ $name } = $newver;
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

  my $prereq = {};

  # regular use and require
  my $includes = $ppi_doc->find('Statement::Include') || [];
  for my $node ( @$includes ) {
    # minimum perl version
    if ( $node->version ) {
      $self->_add_prereq($prereq, perl => $node->version);
      next;
    }

    # skipping pragamata
    next if $node->module ~~ [ qw{ strict warnings lib } ];

    if ( $node->module ~~ [ qw{ base parent } ] ) {
      # the content is in the 5th token
      my @meat = $node->arguments;

      my @parents = map { $self->_q_contents($_) } @meat;
      $self->_add_prereq($prereq, $_ => 0) for @parents;
    }

    # regular modules
    my $version = $node->module_version ? $node->module_version->content : 0;

    # base has been core since perl 5.0
    next if $node->module eq 'base' and not $version;

    $self->_add_prereq($prereq, $node->module => $version);
  }

  # Moose-based roles / inheritance
  my @bases =
    map  { $self->_q_contents( $_ ) }
    grep { $_->isa('PPI::Token::Quote') || $_->isa('PPI::Token::QuoteLike') }
    map  { $_->children }
    grep { $_->child(0)->literal ~~ [ qw{ with extends } ] }
    grep { $_->child(0)->isa('PPI::Token::Word') }
    @{ $ppi_doc->find('PPI::Statement') || [] };

  $self->_add_prereq($prereq, $_ => 0) for @bases;

  return $prereq;
}

1;


=pod

=head1 NAME

Perl::PrereqScanner - a tool to scan your Perl code for its prerequisites

=head1 VERSION

version 0.100491

=head1 SYNOPSIS

  use Perl::PrereqScanner;
  my $scan    = Perl::PrereqScanner->new;
  my $prereqs = $scan->scan_ppi_document( $ppi_doc );
  my $prereqs = $scan->scan_file( $file_path );
  my $prereqs = $scan->scan_string( $perl_code );

  # or using class methods
  my $prereqs = Perl::PrereqScanner->scan_ppi_document( $ppi_doc );

=head1 DESCRIPTION

The scanner will extract loosely your distribution prerequisites from your
files.

The extraction may not be perfect but tries to do its best. It will currently
find the following prereqs:

=over 4

=item * plain lines beginning with C<use> or C<require> in your perl
modules and scripts. This includes minimum perl version.

=item * regular inheritance declated with the C<base> and C<parent>
pragamata.

=item * L<Moose> inheritance declared with the C<extends> keyword.

=item * L<Moose> roles included with the C<with> keyword.

=back

It will trim the following pragamata: C<strict>, C<warnings>, C<base>
and C<lib>. However, C<parent> is kept, since it's not in a core module.

=head1 METHODS

=head2 my $prereqs = $scanner->scan_string( $perl_code );

Return a list of prereqs with their minimum version (0 if no minimum
specified) given a string of Perl code.

=head2 my $prereqs = $scanner->scan_file( $path );

Return a list of prereqs with their minimum version (0 if no minimum
specified) given a path to a Perl file.

=head2 my $prereqs = $scanner->scan_ppi_document( $ppi_doc );

Return a list of prereqs with their minimum version (0 if no minimum
specified) given a L<PPI> document.

=for Pod::Coverage::TrustPod new

=head1 AUTHOR

  Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

