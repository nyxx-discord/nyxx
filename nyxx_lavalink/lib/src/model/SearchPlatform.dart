part of nyxx_lavalink;

/// Search platforms supported by Lavalink
enum SearchPlatform {
  /// Youtube
  youtube,

  /// Youtube Music
  youtubeMusic,

  /// SoundCloud
  soundcloud,
}

/// String presentation of the platform
const Map<SearchPlatform, String> _stringPlatform = {
  SearchPlatform.youtube: "ytsearch",
  SearchPlatform.youtubeMusic: "ytmsearch",
  SearchPlatform.soundcloud: "scsearch",
};
