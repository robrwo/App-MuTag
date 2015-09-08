use Test::Most;

use v5.10.1;

use_ok 'Audio::TagLib::Simple';
use_ok 'App::MuTag::Util';

subtest 'parse_string' => sub {

  my $patt = '(?<TPOS>\d)?-?(?<TRCK>\d\d)(?: |-| - )(?<TIT2>[^- ].+)';

  is_deeply
    parse_string($patt, '10-Foo'),
    {
     TIT2 => 'Foo',
     TRCK => 10,
    };

    is_deeply
    parse_string($patt, '10 - Foo'),
    {
     TIT2 => 'Foo',
     TRCK => 10,
    };

  is_deeply
    parse_string($patt, '201 Foo'),
    {
     TIT2 => 'Foo',
     TRCK => '01',
     TPOS => 2,
    };

  is_deeply
    parse_string($patt, '2-01 Foo'),
    {
     TIT2 => 'Foo',
     TRCK => '01',
     TPOS => 2,
    };

  is
    parse_string($patt, 'Foo'),
    undef;
};

subtest 'parse_string (aliases)' => sub {

  my $patt = '(?<disk>\d)?-?(?<trck>\d\d)(?: |-| - )(?<sort-title>[^- ].+)';

  is_deeply
    parse_string($patt, '10-Foo'),
    {
     TSOT => 'Foo',
     TRCK => 10,
    };

    is_deeply
    parse_string($patt, '10 - Foo'),
    {
     TSOT => 'Foo',
     TRCK => 10,
    };

  is_deeply
    parse_string($patt, '201 Foo'),
    {
     TSOT => 'Foo',
     TRCK => '01',
     TPOS => 2,
    };

  is_deeply
    parse_string($patt, '2-01 Foo'),
    {
     TSOT => 'Foo',
     TRCK => '01',
     TPOS => 2,
    };

  is
    parse_string($patt, 'Foo'),
    undef;
};

subtest 'sort_order' => sub {
  my $prefix = 'An?|The';
  is sort_order('The Foo', $prefix), 'Foo, The';
  is sort_order('A Foo', $prefix),   'Foo, A';
  is sort_order('An Foo', $prefix),  'Foo, An';
  is sort_order('Foo', $prefix),     undef;
};

subtest 'text_from' => sub {
  ok my $mp3 = Audio::TagLib::Simple->new('t/data/sample.mp3'), 'new Audio::TagLib::Simple'
    or BAIL_OUT 'Unable to create test object';
  is text_from($mp3, 'filename'), 'sample.mp3', 'filename';
  is text_from($mp3, 'dirname'), 'data', 'dirname';
  is text_from($mp3, 'pathname'), 't/data/sample.mp3', 'pathname';
  is text_from($mp3, 'title'), 'Bells', 'title';
  is text_from($mp3, 'tit2'),  'Bells', 'tit2';
  is text_from($mp3, 'TIT2'),  'Bells', 'TIT2';
  is text_from($mp3, 'XXXX'), undef, 'XXXX';
};

subtest 'trim_whitespace' => sub {
  is trim_whitespace('  A  B C  '), 'A B C';
};

done_testing;
