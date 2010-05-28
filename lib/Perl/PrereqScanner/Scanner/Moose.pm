package Perl::PrereqScanner::Scanner::Moose;
BEGIN {
  $Perl::PrereqScanner::Scanner::Moose::VERSION = '0.101480';
}
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: scan for Moose sugar indicators of required modules


sub scan_for_prereqs {
  my ($self, $ppi_doc, $req) = @_;

  # Moose-based roles / inheritance
  my @bases =
    map  { $self->_q_contents( $_ ) }
    grep { $_->isa('PPI::Token::Quote') || $_->isa('PPI::Token::QuoteLike') }
    map  { $_->children }
    grep { $_->child(0)->literal =~ m{\Awith|extends\z} }
    grep { $_->child(0)->isa('PPI::Token::Word') }
    @{ $ppi_doc->find('PPI::Statement') || [] };

  $req->add_minimum($_ => 0) for @bases;
}

1;

__END__
=pod

=head1 NAME

Perl::PrereqScanner::Scanner::Moose - scan for Moose sugar indicators of required modules

=head1 VERSION

version 0.101480

=head1 DESCRIPTION

This scanner will look for the following indicators:

=over 4

=item *

L<Moose> inheritance declared with the C<extends> keyword

=item *

L<Moose> roles included with the C<with> keyword

=back

=head1 AUTHORS

  Jerome Quelin
  Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

