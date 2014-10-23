use strict;
use warnings;

package Perl::PrereqScanner::Scanner::Perl5;
{
  $Perl::PrereqScanner::Scanner::Perl5::VERSION = '1.007';
}
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: scan for core Perl 5 language indicators of required modules


sub scan_for_prereqs {
  my ($self, $ppi_doc, $req) = @_;

  # regular use and require
  my $includes = $ppi_doc->find('Statement::Include') || [];
  for my $node ( @$includes ) {
    # minimum perl version
    if ( $node->version ) {
      $req->add_minimum(perl => $node->version);
      next;
    }

    # skip lib.pm
    # lib.pm is not indexed in 02packages, so listing it as a prereq is not a
    # good idea. -- rjbs, 2011-08-17
    next if grep { $_ eq $node->module } qw{ lib };

    # inheritance
    if (grep { $_ eq $node->module } qw{ base parent }) {
      # rt#55713: skip arguments to base or parent, focus only on inheritance
      my @meat = grep {
           $_->isa('PPI::Token::QuoteLike::Words')
        || $_->isa('PPI::Token::Quote')
        } $node->arguments;

      my @parents = map { $self->_q_contents($_) } @meat;
      $req->add_minimum($_ => 0) for @parents;
    }

    # regular modules
    my $version = $node->module_version ? $node->module_version->content : 0;

    # rt#55851: 'require $foo;' shouldn't add any prereq
    $req->add_minimum($node->module, $version) if $node->module;
  }
}

1;

__END__
=pod

=head1 NAME

Perl::PrereqScanner::Scanner::Perl5 - scan for core Perl 5 language indicators of required modules

=head1 VERSION

version 1.007

=head1 DESCRIPTION

This scanner will look for the following indicators:

=over 4

=item *

plain lines beginning with C<use> or C<require> in your perl modules and scripts, including minimum perl version

=item *

regular inheritance declared with the C<base> and C<parent> pragmata

=back

=head1 AUTHORS

=over 4

=item *

Jerome Quelin

=item *

Ricardo Signes <rjbs@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

