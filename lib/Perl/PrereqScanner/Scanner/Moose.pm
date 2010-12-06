use strict;
use warnings;

package Perl::PrereqScanner::Scanner::Moose;
BEGIN {
  $Perl::PrereqScanner::Scanner::Moose::VERSION = '1.000';
}
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: scan for Moose sugar indicators of required modules


sub scan_for_prereqs {
  my ($self, $ppi_doc, $req) = @_;

  # Moose-based roles / inheritance
  my @chunks =
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

    map  { [ $_->children ] }
    grep { $_->child(0)->literal =~ m{\Awith|extends\z} }
    grep { $_->child(0)->isa('PPI::Token::Word') }
    @{ $ppi_doc->find('PPI::Statement') || [] };

  foreach my $hunk ( @chunks ) {
    # roles/inheritance *WITH* version declaration ( added in Moose 1.03 )
    if ( grep { $_->isa('PPI::Structure::Constructor') || $_->isa('PPI::Structure::List') } @$hunk ) {
      # hack for List
      my @hunkdata = @$hunk;
      while ( $hunkdata[0]->isa('PPI::Token::Whitespace') ) { shift @hunkdata }
      if ( $hunkdata[1]->isa('PPI::Structure::List') ) {
        @hunkdata = $hunkdata[1]->children;
        while ( $hunkdata[0]->isa('PPI::Token::Whitespace') ) { shift @hunkdata }
      }
      if ( $hunkdata[0]->isa('PPI::Statement::Expression') ) {
        @hunkdata = $hunkdata[0]->children;
      }

      # possibly contains a version declaration!
      my( $pkg, $done );
      foreach my $elem ( @hunkdata ) {
        # Scan for the first quote-like word, which is the package name
        if ( $elem->isa('PPI::Token::Quote') || $elem->isa('PPI::Token::QuoteLike') ) {
          # found a new package and the previous one didn't have a version?
          if ( defined $pkg ) {
            $req->add_minimum( $pkg => 0 );
          }
          $pkg = ( $self->_q_contents( $elem ) )[0];
          undef $done;
          next;
        }

        # skip over the fluff and look for the version block
        if ( $pkg and $elem->isa('PPI::Structure::Constructor') ) {
          foreach my $subelem ( $elem->children ) {
            # skip over the fluff and look for the real version code
            if ( $subelem->isa('PPI::Statement') ) {
              my $found_ver;
              foreach my $code ( $subelem->children ) {
                # skip over the fluff until we're sure we saw the version declaration
                if ( $code->isa('PPI::Token::Word') and $code->literal eq '-version' ) {
                  $found_ver++;
                  next;
                }

                if ( $found_ver and ( $code->isa('PPI::Token::Quote') || $code->isa('PPI::Token::QuoteLike') || $code->isa('PPI::Token::Number') ) ) {
                  $req->add_minimum( $pkg => ( $self->_q_contents( $code ) )[0] );
                  $done++;
                  undef $pkg;
                  last;
                }
              }

              # Did we fail to find the ver?
              if ( $found_ver and ! $done ) {
                die "Possible internal error!";
              }
            }
          }

          # Failed to find version-specific stuff
          if ( ! $done ) {
            $req->add_minimum( $pkg => 0 );
            undef $pkg;
            next;
          }
        }
      }

      # If we found a pkg but no done, this must be the "last" pkg to be declared and it has no version
      if ( $pkg and ! $done ) {
        $req->add_minimum( $pkg => 0 );
      }
    } else {
      # no version or funky blocks in code, yay!
      $req->add_minimum( $_ => 0 ) for
        grep { Params::Util::_CLASS($_) }
        map  { $self->_q_contents( $_ ) }
        grep { $_->isa('PPI::Token::Quote') || $_->isa('PPI::Token::QuoteLike') }
        @$hunk;
    }
  }
}

1;

__END__
=pod

=head1 NAME

Perl::PrereqScanner::Scanner::Moose - scan for Moose sugar indicators of required modules

=head1 VERSION

version 1.000

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

