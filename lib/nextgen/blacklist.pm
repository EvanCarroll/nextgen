package nextgen::blacklist;
use strict;
use warnings;
use feature ':5.10';

# http://scsys.co.uk:8002/52489

my %prohibited;

sub check {
	my $file = shift;
	my $callers_pkg = (caller(1))[0];

	my $pkg_bl_db = $prohibited{ $callers_pkg };
	my $class = _pmfile_to_class( $file );

	if ( exists $pkg_bl_db->{$file} ) {
		die sprintf(
			"nextgen::blacklist violation with import attempt for: [ %s (%s) ] try 'use %s' instead.\n%s\n"
			, $class
			, $file
			, $pkg_bl_db->{$file}{'replacement'}
			, $pkg_bl_db->{$file}{'reason'}
		);
	}

	return;

};

sub import {
	my ( $self, $args, $bl ) = @_;

	my $callee = $bl->{'-callee'} // scalar(caller);

	$prohibited{$callee} = $args;

	state $installed = 0;
	unless ( $installed == 1) {
		my $NEXT_REQUIRE;
		if ( *CORE::GLOBAL::require{CODE} ) {
			$NEXT_REQUIRE = \&{*CORE::GLOBAL::require{CODE}};
		}
		
		*CORE::GLOBAL::require = sub {
			nextgen::blacklist::check(@_);
			$NEXT_REQUIRE ? $NEXT_REQUIRE->(@_) : CORE::require(@_);
		};
		
		$installed = 1;
	}

}

sub _pmfile_to_class {
	my $pmfile = shift;
	( my $class = $pmfile ) =~ s{/}{::}g;
	$class =~ s/\.pm$//i;
	return $class;
}

## This one was stole right from Class::MOP
sub _class_to_pmfile {
	my $class = shift;
	my $file = $class . '.pm';
	$file =~ s{::}{/}g;
	return $file;
}

1;

__END__

Syntax desired:

nextgen::blacklist->import(
	{Date::Manip => 'Use DateTime instead'}
	, { -callee => scalar(caller) }
)
