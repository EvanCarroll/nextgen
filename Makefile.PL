use inc::Module::Install;

name     'nextgen';
all_from 'lib/nextgen.pm';
author   q{Evan Carroll <me@evancarroll.com>};
license  'perl';

perl_version '5.10.1';

build_requires 'Test::More';

requires 'indirect';
requires 'autodie';
requires 'B::Hooks::EndOfScope';
requires 'namespace::autoclean';

requires 'Moose';
requires 'oose';
requires 'IO::Handle';
requires 'mro';
requires 'utf8';
requires 'feature';
requires 'strict';
requires 'warnings';

repository 'git://github.com/EvanCarroll/nextgen.git';
homepage   'http://www.evancarroll.com';

auto_install;

WriteAll;
