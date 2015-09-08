package App::MuTag::Consts;

use Const::Exporter

  default =>
  [
   '%FRAME_ALIASES' =>
   {
    album                => 'TALB',
    album_artist         => 'TPE2',
    artist               => 'TPE1',
    artist_accompaniment => 'TPE3',
    artist_remix         => 'TPE4',
    composer             => 'TCOM',
    disk                 => 'TPOS',
    disk_title           => 'TSST',
    genre                => 'TCON',
    original_album       => 'TOAL',
    original_artist      => 'TOPE',
    preferred_filename   => 'TOFN', # aka original filename
    release_year         => 'TDOR',
    sort_album           => 'TSOA',
    sort_album_artist    => 'TSO2',
    sort_artist          => 'TSOP',
    sort_composer        => 'TSOC',
    sort_title           => 'TSOT',
    subtitle             => 'TIT3',
    title                => 'TIT2',
    track                => 'TRCK',
    url                  => 'WXXX', # TODO: description
    user_text            => 'TXXX', # TODO: description
    year                 => 'TDRC', # aka recording-time
   },

 '%SORT_FRAMES' =>
   {
   TPE1 => 'TSOP',
   TPE2 => 'TSOP',
   TALB => 'TSOA',
   TIT2 => 'TSOT',
   TCOM => 'TSOC',
   TPE2 => 'TSO2'
  },

  ];

1;
