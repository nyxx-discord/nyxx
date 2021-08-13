part of nyxx_lavalink;

/// Search platforms supported by Lavalink
class SearchPlatform extends IEnum<String> {
  /// Youtube
  static const youtube = SearchPlatform._create("ytsearch");

  /// Youtube Music
  static const youtubeMusic = SearchPlatform._create("ytmsearch");

  /// SoundCloud
  static const soundcloud = SearchPlatform._create("scsearch");

  const SearchPlatform._create(String value) : super(value);
}
