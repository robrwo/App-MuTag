use Moops;

class Audio::TagLib::Simple {

use Audio::TagLib::MPEG::File;
use Audio::TagLib::Simple::Frame;
use PerlX::Maybe;

has filename => (
    is => 'ro',
    isa => Str,
    required => 1,
    );

  has file => (
      is => 'lazy',
      isa => InstanceOf['Audio::TagLib::File'],
      default => method() { Audio::TagLib::MPEG::File->new($self->filename) },
      handles => {
          tag  => 'ID3v2Tag',
          save => 'save',
          },
      );

  has map => (
      is => 'lazy',
      isa => InstanceOf['Audio::TagLib::ID3v2::FrameListMap'],
      default => method() { $self->tag->frameListMap },
      );

  method has_frame(Str $id) {
      my $key = Audio::TagLib::ByteVector->new($id);
      my $map = $self->map;
      return $map->contains($key);
  }

  method get_frames(Str $id?) {

      if (defined $id) {

          my $key = Audio::TagLib::ByteVector->new($id);
          my $map = $self->map;
          if ($map->contains($key)) {
              my $list = $map->getItem($key);
              my $size = $list->size;
              my @frames = map { Audio::TagLib::Simple::Frame->new($list->getItem($_-1))  } (1..$size);
              return @frames;
          } else {
              return;
          }
        } else {
          my $tag  = $self->tag or die $self->filename;
          my $list = $tag->frameList;
          my $size = $list->size;
          my @frames = map { Audio::TagLib::Simple::Frame->new($list->getItem($_-1))  } (1..$size);
          return @frames;
      }

  }

  method add_frame(Str $id, Str $text?) {
      my $frame = Audio::TagLib::Simple::Frame->new( id => $id, maybe text => $text );
      $self->tag->addFrame($frame->frame);
      return $frame;
  }

  method add_frame_if_missing(Str $id, Str $text) {
     $self->add_frame($id, $text) unless $self->has_frame($id);
  }

  method remove_frame($frame) {
    $self->tag->removeFrame($frame->frame);
  }

  method BUILDARGS(@args) {

      if (@args == 1) {
          my $arg = shift @args;
          @args = ( filename => $arg );
      }

      return { @args };
  }

}
