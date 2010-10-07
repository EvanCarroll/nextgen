package nextgen;
use strict;
use warnings;

our $VERSION = '0.05';

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

use nextgen::blacklist;

sub import {
	my ( $class, %args ) = @_;

	my @caller = caller;
	my $pkg = $caller[0];

	## nextgen->import() is a noop in pkg main using perl -Mnextgen -e''
	if (
		$caller[2] == 0 # line
		&& $caller[1] eq '-e' && $0 eq '-e'
	) {
		return ()
	}

	my $procedural = (
		$pkg eq 'main'
		|| defined $args{'mode'} && $args{'mode'} ~~ qr/:procedural/
	) ? 1 : 0
	;

	feature->import(':5.10');
	indirect->unimport(':fatal');
	autodie->import();

	## Moose will import warnings and strict by default
	if ( !$procedural && $pkg ne 'main' ) {
		mro::set_mro( $pkg, 'c3' );
		
		Moose->import({ 'into' => $pkg })
			unless $pkg->can('meta')
		;
		
		## Cleanup if the package has a new or meta (Moose::Roles)
		on_scope_end( sub {
			no strict qw/refs/;
			no warnings;
			namespace::autoclean->import( -cleanee => $pkg )
				if defined $pkg->can('new')
				|| defined $pkg->can('meta')
			;
		} )
	
	}
	else {	
		warnings->import();
		strict->import();
	}
		
	state $nextgen_default_blacklist = {
		'base.pm' => {
			replacement => 'parent'
		}
		, 'Class/Accessor.pm' => {
			replacement => 'Moose'
		}
		, 'Class/Accessor/Fast.pm' => {
			replacement => 'Moose'
		}
		, 'Class/Accessor/Faster.pm' => {
			replacement => 'Moose'
		}
		, 'NEXT.pm' => {
			replacement => 'mro'
		}
		, 'strict.pm'    => {
			replacement => 'nextgen'
		}
		, 'warnings.pm'  => {
			replacement => 'nextgen'
		}
		, 'autodie.pm'   => {
			replacement => 'nextgen'
		}
	};

	nextgen::blacklist->import(
		$nextgen_default_blacklist
		, { -callee => $pkg }
	);
	
}



## This is here for a reason (and I prefer to use oose.pm, even though I could
## just as well reimpliment it).
## http://search.cpan.org/~dconway/Filter-Simple/lib/Filter/Simple.pm#Using_Filter::Simple_with_an_explicit_import_subroutine
use if $0 eq '-e', "Filter::Simple" => sub { s/^/use oose; \n use nextgen;/ };

1;

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


But the joy doens't stop there, here are some examples of the command line.

    perl -Mnextgen -E'say Class->new->meta->name'
    
    # You can see warnings is on:
    perl -Mnextgen -E'(undef) + 5'
    
    # And, strict
    perl -Mnextgen -E'my $foo = "bar"; $$foo = 4; say $$foo'
    
    #	And, it wouldn't be nextgen if this was allowed.	
    perl -Mnextgen -E'use NEXT;'
    
    # Or, this
    perl -Mnextgen -MNEXT -e1

But the joy doesn't stop there, here are some examples in module.

    package Foo;
    ## easier than strict, warnings, indirect, autodie, mro-c3, Moose, and blacklist
    use nextgen;
    
    ## vanilla Moose to follow
    has "foo" => ( isa => "Str", is => "rw" )
    
    package main;
    use nextgen;
    
    ## this works
    my $o = Foo->new;
    
    ## this wouldn't
    ## main is understood to be mode => [qw/procedural])
    my $o = main->new

For now, this module just does

=over 12

=item Perl assertion

asserts 5.10.1+ is loaded -- 5.10.0 is unsupported and not forwards
  compatable because of smart match.

=item strict and warnings

uses the vanilla L<strict>, and L<warnings> pragmas

=item features.pm

adds Perl 5.10 L<features>

=item indirect.pm

disables indirect method syntax via L<indirect>

=item autodie.pm

throws fatal exceptions in a sane fashion for CORE functions via L<autodie>

=item mro.pm

C3 method resolution order via L<mro>

=item Moose.pm

adds L<Moose> if the package isn't main

=item oose.pm

uses L<oose>.pm if the program is run via C<perl -e>, or C<perl -E>

=item namespace/autoclean.pm

cleans up the class via L<namespace::autoclean> if the module has a constructor (sub new).

In the future, L<nextgen> will include additional CPAN modules which have proven useful and stable.

=back

This module started out as a fork of L<Modern::Perl>, it wasn't modern enough
and the author wasn't attentive enough to the needs for a more modern perl5.

=head1 PROCEDURAL CODE

If you wish to write L<nextgen> module that doesn't assume non-"main" packages
are object-oriented classes, then use the B<:procedural> token:

    use nextgen mode => [qw(:procedural)]

    or even

    use nextgen mode => qw(:procedural)

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

=head2 Original Modern::Perl author

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

