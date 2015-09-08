use Test::Most;
use Test::Trap;

use_ok 'App::MuTag::Options';

use App::MuTag::Consts;

subtest 'frame aliases' => sub {

  my $count = 1;
  foreach my $alias (keys %FRAME_ALIASES) {

    subtest $alias => sub {

      my $opt = $alias =~ s/_/-/gr;
      local @ARGV = ( "--${opt}", $count);

      ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

      is_deeply $app->frame, { $FRAME_ALIASES{$alias} => $count++ }, 'frame';

    };

  }

};

subtest 'delete-frame' => sub {

  local @ARGV = ( '--delete_frame', 'TDRC', '--delete_frame', 'tit2,tpos' );

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  is_deeply $app->frame, { TDRC => undef, TIT2 => undef, TPOS => undef }, 'frame';

};

subtest 'auto-sort' => sub {

  local @ARGV = ('--sort_artist', 'Ayler, Albert', '--auto_sort');

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  is_deeply $app->frame, { TSOP => 'Ayler, Albert', TPE1 => 'Albert Ayler' }, 'frame';

};

subtest 'save' => sub {

  local @ARGV = ('--save');

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  ok !$app->dry_run, '!dry-run';

};

subtest 'save+no-dry-run' => sub {

  local @ARGV = ('--save', '--no-dry-run');

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  ok !$app->dry_run, '!dry-run';

};

subtest 'no-save' => sub {

  local @ARGV = ('--no-save');

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  ok $app->dry_run, 'dry-run';

};

subtest 'no-save+dry-run' => sub {

  local @ARGV = ('--no-save', '--dry-run');

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  ok $app->dry_run, 'dry-run';

};

subtest 'save+dry-run' => sub {

  local @ARGV = ('--save', '--dry-run');

  my @r = trap {
    my $app = App::MuTag::Options->new_with_options();
  };

  like $trap->stderr, qr/Conflicting dry-run and save options/, 'error';

};

subtest 'no+save+no-dry-run' => sub {

  local @ARGV = ('--no-save', '--no-dry-run');

  my @r = trap {
    my $app = App::MuTag::Options->new_with_options();
  };

  like $trap->stderr, qr/Conflicting dry-run and save options/, 'error';

};

subtest 'parse-title' => sub {

  local @ARGV = ( '--parse-title' );

  ok my $app = App::MuTag::Options->new_with_options(), 'new_with_options';

  is $app->parse_from, 'title', '--parse-from title';

};

done_testing;
