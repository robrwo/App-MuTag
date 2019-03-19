use Moops;

class App::MuTag extends App::MuTag::Options {

use File::Find::Rule;
use Path::Tiny;

use App::MuTag::Consts;
use App::MuTag::Util;
use Audio::TagLib::Simple;

use version 0.77;
our $VERSION = version->declare('v0.1.2');

method set_frame($mp3, Str $id, Str $text) {
  if (my ($frame) = $mp3->get_frames($id)) {
    $frame->text($text) if $self->overwrite;
  } else {
    $mp3->add_frame($id, $text);
  }
}

method parse_from_file($mp3) {

  if ($self->set_title_from_filename) {
    my $text = text_from($mp3, 'filename');
    $text =~ s/\s*[.]mp3$//i;
    $self->set_frame($mp3, 'TIT2', $text);
  }

  if ($self->set_album_from_dirname) {
    my $text = text_from($mp3, 'dirname');
    $self->set_frame($mp3, 'TALB', $text);
  }

  my $from = $self->parse_from or return;
  my $patt = $self->parse_pattern or return;
  my $text = text_from($mp3, $from);

  if (defined $text) {
    my $frames = parse_string($patt, $text) or return;
    foreach my $id (keys %{$frames}) {
      $self->set_frame($mp3, $id, $frames->{$id});
    }
  }

}

method fix_sorting($mp3) {
  return unless $self->auto_sort;

  foreach my $id (keys %SORT_FRAMES) {
    my ($frame) = $mp3->get_frames($id) or next;
    if (my $text = sort_order($frame->text, $self->sort_prefix)) {
      my $sort_id = $SORT_FRAMES{$id};
      $self->set_frame($mp3, $sort_id, $text);
    }
  }
}

method clean_metadata($mp3) {

  # TODO: auto-track option?
    # TODO: if overwrite, then the track count should be enforced in apply

  if (my ($frame) = $mp3->get_frames('TRCK')) {
    if (my $text = $frame->text) {
      if (my ($track, $count) = $text =~ /^(\d+)(\/\d+)?$/) {
        $count //= $self->track_count;
        $count = substr($count,1) if substr($count,0,1) eq '/';
        $track = sprintf('%d/%d', $track + 0, $count) if $count;
        $frame->text($track);
      }
    }
  }

  if (my ($frame) = $mp3->get_frames('TPOS')) {
    if (my $track = $frame->text + 0) {
      $track = sprintf('%d/%d', $track, $self->disk_count) if $self->disk_count;
      $frame->text($track);
    }
  }

    # TODO: whitespace option
  foreach my $id (qw/ TALB TIT1 TIT2 TIT3 TPE1 TPE2 TPE3 TPE4 TSOA TSOP TSOT
                      TSST TOAL TOPE /) {

    my ($frame) = $mp3->get_frames($id) or next;
    my $text = trim_whitespace( $frame->text );
    $text =~ s/([a-z])/uc($1)/eg;
    $frame->text( $text );

  }

}

method apply_changes($mp3) {
  foreach my $id (keys %{$self->frame}) {
    my $text = $self->frame->{$id};
    my ($frame) = $mp3->get_frames($id);
    if ($frame) {
      if (defined $text) {
        $frame->text($text) if $self->overwrite;
      }
      else {
        $mp3->remove_frame($frame);
      }
    } else {
      $mp3->add_frame($id,$text);
    }
  }
}

method process_file(Str $file) {
    say $file;
    my $mp3 = Audio::TagLib::Simple->new($file);
    $self->clean_metadata($mp3) if $self->clean;
    $self->parse_from_file($mp3);
    $self->apply_changes($mp3);
    $self->fix_sorting($mp3);

    foreach my $frame ($mp3->get_frames) {
        say sprintf(' %s %s', $frame->id, $frame->text);
    }

    $mp3->save unless $self->dry_run;
  }

method process_dir(Str $dir) {
  my @files = File::Find::Rule->file->name('*.mp3')->maxdepth($self->max_depth)->in($dir);
  $self->process_file($_) for @files;
}

method run() {
    foreach my $file (@ARGV) {
      if (-f $file) {
        $self->process_file($file);
      } elsif (-d $file) {
        $self->process_dir($file);
      }

    }
}

}
