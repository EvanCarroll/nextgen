#!/usr/bin/env perl

use Test::More tests => 6;

BEGIN
{
	use_ok( 'nextgen' ) or exit;
	nextgen->import();
}

package Class;
use nextgen mode => [qw(:procedural)];

{
	eval { Class->new };
	Test::More::is( $@, '', ':procedural did not turn this into a Class' );
}

{
	eval "use nextgen;";
	Test::More::is( $@, '', 'use worked without problem (on nextgen)' );
}

{
	eval "use NEXT;";
	Test::More::like( $@, qr/nextgen::blacklist/, 'use on NEXT resulted in black-list exception' );
}

{
	eval "require 'NEXT.pm';";
	Test::More::like( $@, qr/nextgen::blacklist/, 'require on "NEXT.pm" resulted in black-list exception' );
}

{
	eval "require NEXT;";
	Test::More::like( $@, qr/nextgen::blacklist/, 'require on "NEXT" module resulted in black-list exception' );
}

