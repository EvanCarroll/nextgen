package nextgen::blacklist;
use List::Util;

use constant DEBUG => 0;
use if DEBUG => 'Data::Dumper';

my %prohibited;

sub _debug_prohibited {
	use Data::Dumper;
	die Dumper \%prohibited;
}

my $sub = sub {
	my ( $subRef, $file ) = @_;
	my $callers_pkg = (caller)[0];

	if ( DEBUG ) {
		die Dumper [
			'INC CALL'
			, {
				subref => $subRef
				, callers_pkg => $callers_pkg
				, pkg => $file
				, 'caller' => [caller]
			}
		];
	}

	my $pkg_bl_db = $prohibited{ $callers_pkg };
	my $class = _pmfile_to_class( $file );
	
	if ( exists $pkg_bl_db->{$file} ) {
		warn sprintf(
			"nextgen::blacklist violation with import attempt for: [ %s (%s) ] try 'use %s' instead.\n"
			, $class
			, $file
			, $pkg_bl_db->{$file}{'replacement'}
		);
		exit()
	}

	$file;

};

sub import {
	my ( $self, $args, $bl ) = @_;

	my $callee = $bl->{'-callee'} // scalar(caller);

	$prohibited{$callee} = $args;

	unshift @INC, $sub
		unless ref $INC[0] eq 'CODE'
			&& $INC[0] == $sub
	;

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

use nextgen qw/:procedural/;

1;

__END__

Syntax desired:

nextgen::blacklist->import(
	{Date::Manip => 'Use DateTime instead'}
	, { -callee => scalar(caller) }
)
