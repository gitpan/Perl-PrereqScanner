use strict;
use warnings;

package Perl::PrereqScanner::Scanner::TestMore;
BEGIN {
  $Perl::PrereqScanner::Scanner::TestMore::VERSION = '1.001';
}
use Moose;
use List::MoreUtils 'none';
with 'Perl::PrereqScanner::Scanner';

sub scan_for_prereqs {
  my ($self, $ppi_doc, $req) = @_;

  return if none { $_ eq 'Test::More' } $req->required_modules;

  $req->add_minimum('Test::More' => '0.88') if grep {
      $_->isa('PPI::Token::Word') && $_->content eq 'done_testing';
  } map {
      my @c = $_->children;
      @c == 1 ? @c : ()
  } @{ $ppi_doc->find('Statement') || [] }
}

1;

__END__
=pod

=head1 NAME

Perl::PrereqScanner::Scanner::TestMore

=head1 VERSION

version 1.001

=head1 AUTHORS

  Jerome Quelin
  Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

