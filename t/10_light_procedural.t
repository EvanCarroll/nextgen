#!/usr/bin/env perl

use Test::More tests => 2;

BEGIN
{
	use_ok( 'nextgen' ) or exit;
	nextgen->import();
}

package Class;
use nextgen mode => [qw(:procedural)];

eval { Class->new };
Test::More::is( $@, '', ':procedural ' );

