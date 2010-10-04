package nextgen;
use strict;
use warnings;

our $VERSION = '0.01';

## 5.10.0 not forwards compat
use v5.10.1;

## Core
use IO::Handle ();
use mro        ();
use feature    ();

## CPAN procedural
use autodie    ();
use indirect   ();

## CPAN OO
use Moose ();
use B::Hooks::EndOfScope qw(on_scope_end);
use namespace::autoclean ();

BEGIN {
	if ( $0 eq '-e' ) {
		eval "use oose ();";
	}
}

sub import {
	my $pkg = [caller]->[0];
	my $caller = scalar caller;

	## Moose will import warnings and strict by default
	if ( $pkg ne 'main' ) {
		Moose->import({ 'into' => $caller });
		mro::set_mro( $caller, 'c3' );
	}
	else {	
		warnings->import();
		strict->import();
	}
	
	feature->import( ':5.10' );
	indirect->unimport(':fatal');
	autodie->import();

	## Cleanup if the package is a Moose::Object or has sub new
	on_scope_end( sub {
		no strict qw/refs/;
		no warnings;
		namespace::autoclean->import( -cleanee => $caller )
			if defined *{$pkg.'::new'}{CODE}
			|| $pkg->isa('Moose::Object')
		;
	} )

}

__END__

=head1 NAME

nextgen - enable all of the features of next-generation perl 5 with one command

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

The B<nextgen> pragma uses several modules to enable additional features of Perl
and of the CPAN.  Instead of copying and pasting all of these C<use> lines,
instead write only one:

    use nextgen;

For now, this module

=over 12

=item asserts 5.10.1+ is loaded -- 5.10.0 is unsupported and not forwards
      compatable because of smart match.

=item uses the vanilla L<strict>, and L<warnings> pragmas

=item adds Perl 5.10 L<features>

=item disables indirect method syntax via L<indirect>

=item throws fatal exceptions in a sane fashion for CORE functions via L<autodie>

=item C3 method resolution order via L<mro>

=item adds L<Moose> if the package isn't main

=item uses L<oose>.pm if the program is run via C<perl -e>, or C<perl -E>

=item cleans up the class via L<namespace::autoclean> if the module has a constructor (sub new).

In the future, L<nextgen> will include additional CPAN modules which have proven useful and stable.

=back

=head1 AUTHOR

Evan Carroll, C<< <me at evancarroll.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-nextgen at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=nextgen>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc nextgen


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=nextgen>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/nextgen>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/nextgen>

=item * Search CPAN

L<http://search.cpan.org/dist/nextgen/>

=back

=head1 ACKNOWLEDGEMENTS

=head2 Original Modern::Perl submitter

chromatic, C<< <chromatic at wgz.org> >>

=head2 RT Bug report submitters

KSURI



=head1 LICENSE AND COPYRIGHT

Copyright 2010 and into the far and distant future, Evan Carroll.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of nextgen

