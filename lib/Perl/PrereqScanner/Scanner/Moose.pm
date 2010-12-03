package Perl::PrereqScanner::Scanner::Moose;
BEGIN {
  $Perl::PrereqScanner::Scanner::Moose::VERSION = '0.101892';
}
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: scan for Moose sugar indicators of required modules


sub scan_for_prereqs {
  my ($self, $ppi_doc, $req) = @_;

  # Moose-based roles / inheritance
  my @bases =
    grep { Params::Util::_CLASS($_) }
    map  { $self->_q_contents( $_ ) }
    grep { $_->isa('PPI::Token::Quote') || $_->isa('PPI::Token::QuoteLike') }

    # This is what we get when someone does:   with('Foo');
    # The target to get at is the PPI::Token::Quote::Single.
    # -- rjbs, 2010-09-05
    #
    # PPI::Statement
    #   PPI::Token::Word
    #   PPI::Structure::List
    #     PPI::Statement::Expression
    #       PPI::Token::Quote::Single
    #   PPI::Token::Structure

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

version 0.101892

=head1 DESCRIPTION

This scanner will look for the following indicators:

=over 4

=item *

L<Moose> inheritance declared with the C<extends> keyword

=item *

L<Moose> roles included with the C<with> keyword

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

