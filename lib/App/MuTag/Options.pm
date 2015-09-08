use Moops;

class App::MuTag::Options {

use MooX::Options protect_argv => 0;;

use App::MuTag::Consts;

option dry_run => (
    is          => 'ro',
    isa         => Bool,
    default     => 1,
    negativable => 1,
    doc         => 'do not save changes',
);

option save => (
    is          => 'rwp',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'save changes (save as --no-dry-run)',
);

option clean => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'attempt to clean metadata',
);

option overwrite => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'overwrite text if frames exist',
);

option auto_sort => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'derive album/artist/etc from sort-album/artist/etc',
    );

option frame => (
    is     => 'ro',
    isa    => HashRef[Maybe[Str]],
    format => 's%',
    short  => 'f',
    doc    => 'set text for frame',
);

option delete_frame => (
  is        => 'ro',
  isa       => ArrayRef[Str],
  format    => 's@',
  autosplit => 1,
  doc       => 'remove frame',
);

option track_count => (
    is      => 'rw',
    isa     => Int,
    format  => 'i',
    default => 0,
    doc     => 'number of tracks',
);

option disk_count => (
    is      => 'rw',
    isa     => Int,
    format  => 'i',
    default => 0,
    doc     => 'number of tracks',
);

option max_depth => (
    is      => 'rw',
    isa     => Int,
    format  => 'i',
    default => 1,
    doc     => 'maximum depth of a directory search',
);

option parse_pattern => ( # TODO_ alias pattern
  is      => 'ro',
  isa     => Str,
  format  => 's',
  default => '(?<TPOS>\d)?-?(?<TRCK>\d\d)(?: |-| - )(?<TIT2>[^- ].+)',
  doc     => 'parsing pattern',
);

option parse_from => ( # TODO: alias parse
  is      => 'ro',
  isa     => Str,
  format  => 's',
  doc     => 'parse from frame',
);

option parse_title => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    doc         => 'same as --parse-from=title',
);

option sort_prefix => (
  is      => 'ro',
  isa     => Str,
  format  => 's',
  default => 'An?|The',
  doc     => 'sort prefix regex',
);

option set_title_from_filename => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'set title from the filename',
);

option set_album_from_dirname => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    negativable => 1,
    doc         => 'set album from the directory name',
);

foreach my $alias (keys %FRAME_ALIASES) {
  my $id = $FRAME_ALIASES{$alias};
  option $alias => (
      is     => 'ro',
      isa    => Str,
      format => 's',
      doc    => "same as --frame $id=String",
  );
}

method BUILDARGS(ClassName $class: @args) {
  my %args = @args;

  if (delete $args{parse_title}) {
    $args{parse_from} = 'title';
  }

  my $frame = $args{frame} //= { };

    foreach my $id (keys %{$frame}) {
       die "Malformed frame id: '$id'" unless $id =~ /^[A-Z0-9]{4}$/i;
       $frame->{uc $id} = delete $frame->{$id} unless $id eq uc $id;
     }

  foreach my $id (map { split ',', } @{$args{delete_frame}}) {
     $frame->{uc $id} = undef;
   }

  foreach my $alias (keys %FRAME_ALIASES) {
    $frame->{$FRAME_ALIASES{$alias}} = delete $args{$alias} if exists $args{$alias};
  }

  if ($args{auto_sort}) {
    foreach my $id (keys %SORT_FRAMES) {
      next if exists $frame->{$id};
      my $sort_id = $SORT_FRAMES{$id};
      if (my $text = $frame->{$sort_id}) {
        my ($last, $first, $extra) = split /[,]\s*/, $text;
        $frame->{$id} = "${first} ${last}" unless defined $extra;
      }
    }
  }

  if (my $from = $args{parse_from}) {
    # TODO: validate: dirname, filename, or frame alias or frame
  }

  if (exists $args{save}) {
    my $save = delete $args{save};
    if (defined $args{dry_run}) {
      if ($args{dry_run} == $save) {
        die "Conflicting dry-run and save options";
      }
    } else {
      $args{dry_run} = !$save;
    }

  }

  return \%args;
}

}

1;
