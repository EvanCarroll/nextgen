#!/usr/bin/env perl

use Test::More tests => 4;
use nextgen;

BEGIN
{
	use_ok( 'nextgen' ) or exit;
	nextgen->import();
}


eval 'say "# say() should be available";';
is( $@, '', 'say() should be available' );

eval '$x = 1;';
like( $@, qr/Global symbol "\$x" requires explicit/,
    'strict should be enabled' );

my $warnings;
local $SIG{__WARN__} = sub { $warnings = shift };
my $y =~ s/hi//;
like( $warnings, qr/Use of uninitialized value/, 'warnings should be enabled' );

## Can't test this which seems to generate parser error
## eval { new D };
## like ( $@, qr/Indirect call of method "new"/, 'indirect' )
