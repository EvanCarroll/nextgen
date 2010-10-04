#!/usr/bin/env perl

use Test::More tests => 3;

BEGIN
{
	use_ok( 'nextgen' ) or exit;
	nextgen->import();
}

eval { Class->new };
like (
	$@
	, qr/Can't locate object method "new" via package "Class"/
	, "No source oose.pm source filter on real for $0"
);


## Change name of running process
$0 = '-e';
delete $INC{'nextgen.pm'};
require 'nextgen.pm';
nextgen->import();

eval { Class->new };
is ( $@, '', 'have an oose.pm new' );
