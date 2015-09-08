use Test::Most;

use_ok 'Audio::TagLib::Simple::Frame';

ok my $frame = Audio::TagLib::Simple::Frame->new('TPE2'), 'new frame';
is $frame->id, 'TPE2';

done_testing;
