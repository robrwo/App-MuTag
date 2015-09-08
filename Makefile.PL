use v5.10;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name 'App-MuTag';
all_from 'lib/App/MuTag.pm';
license 'artistic_2';

perl_version 5.010;

tests_recursive('t');

# tests_recursive('xt');

resources(
    homepage   => 'http://rrwo.tumblr.com',
    license    => 'http://www.perlfoundation.org/artistic_license_2_0',
);

configure_requires();

build_requires();

requires(
    'Audio::TagLib' => 0,
    'Const::Exporter' => 0,
    'Const::Fast' => 0,
    'Exporter' => 0,
    'File::Find::Rule' => 0,
    'Kavorka' => 0,
    'MooX::Options' => 0,
    'Moops' => 0,
    'Path::Tiny' => 0,
    'PerlX::Maybe' => 0,
    'strictures' => 0,
);

recommends(
  'PerlX::Maybe::XS' => 0,
);

test_requires(
  'Test::Most'       => 0,
  'Test::Trap'       => 0,
);

install_script(
    'bin/mu-tag',
);

install_as_cpan;
auto_install;
WriteAll;
