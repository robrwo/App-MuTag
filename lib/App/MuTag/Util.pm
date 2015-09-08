package App::MuTag::Util;

use v5.10.0;

use strictures;

use Exporter qw/ import /;
use Kavorka;
use Path::Tiny;

use App::MuTag::Consts;

our @EXPORT = qw/ parse_string sort_order text_from trim_whitespace /;
our @EXPORT_OK = @EXPORT;

fun normalize_alias(Str $key --> Maybe[Str]) {
  my $alias = $key =~ s/-/_/gr;
  if (exists $FRAME_ALIASES{$alias}) {
    return $FRAME_ALIASES{$alias};
  }
  else {
    return;
  }
}

fun parse_string( Str $pattern, Str $text --> Maybe[HashRef] ) {

  state $replace = fun(Str $key) {
    sprintf('<%s>', normalize_alias($key) // uc($key));
    };
  $pattern =~ s/\<(\w+(?:-\w+)*)\>/$replace->($1)/ge;

  my $regex = qr/^${pattern}$/;
  if ($text =~ $regex) {
    return { %+ };
  }
  else {
    return;
  }
}

fun sort_order( Str $text, Str $prefix --> Maybe[Str] ) {
  my $regex = qr/^(?<prefix>${prefix})\s+(?<title>.+)$/;
    if ($text =~ $regex) {
        return "$+{title}, $+{prefix}";
    } else {
        return;
    }
}

fun text_from($mp3, Str $from --> Maybe[Str]) {

  return path($mp3->filename)->basename                if $from eq 'filename';
  return path(path($mp3->filename)->dirname)->basename if $from eq 'dirname';
  return $mp3->filename                                if $from eq 'pathname';

  $from =~ s/-/_/g;
  my $id = normalize_alias($from) // uc($from);
  if ($mp3->has_frame($id)) {
    my ($frame) = $mp3->get_frames($id);
    return $frame->text;
  }

  return;
}


fun trim_whitespace(Str $text --> Str) {
  $text =~ s/^\s+//;
  $text =~ s/\s+$//;
  $text =~ s/\s\s+/ /gr;
}


1;
