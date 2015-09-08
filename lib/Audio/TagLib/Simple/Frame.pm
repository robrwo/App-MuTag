use Moops;

class Audio::TagLib::Simple::Frame {

    use feature 'state';

    use Audio::TagLib::ByteVector;
    use Audio::TagLib::ID3v2::Frame;
    use Audio::TagLib::ID3v2::FrameFactory;
    use Audio::TagLib::ID3v2::Header;
    use Audio::TagLib::String;

    has frame => (
        is => 'lazy',
        isa => InstanceOf['Audio::TagLib::ID3v2::Frame'],
        builder => 1,
        );

    method _build_frame() {

state $factory = Audio::TagLib::ID3v2::FrameFactory->instance();
$factory->setDefaultTextEncoding('UTF8');

my $data = Audio::TagLib::ByteVector->new ($self->id .               # Frame ID
                                           "\x00\x00\x00\x13" .   # Frame size
                                           "\x00\x00" .           # Frame flags
                                           "\x00"                 # Encoding
                                           , 23);

my $header = Audio::TagLib::ID3v2::Header->new($data);

my $frame = $factory->createFrame($data, $header)
  or die "Unable to create frame for " . $self->id;

my $str = Audio::TagLib::String->new($self->text // '');
$frame->setText($str);

return $frame;
    }

    has id => (
        is => 'lazy',
        isa => Str, # TODO: exactly 4 characters
        default => method() { $self->frame->frameID->data },
        );

    has text => (
        is => 'rw',
        isa => Str,
        lazy => 1,
        default => method() { $self->frame->toString->toCString },
        trigger => 1,
        predicate => 1,
        );

    method _trigger_text(Str $new, Str $old?) {
        my $str = Audio::TagLib::String->new($new);
        $self->frame->setText($str);
     }

    method BUILDARGS(@args) {
        if (@args == 1) {
            my $arg = shift @args;
            if (blessed($arg)) {
                @args = ( frame => $arg );
            } else {
                @args = ( id => $arg );
            }
        }
        return { @args };
    }

}
