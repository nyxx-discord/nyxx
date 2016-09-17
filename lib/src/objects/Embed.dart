import '../objects.dart';

/// A message embed.
class Embed {
  /// The embed's URL
  String url;

  /// The embed's type
  String type;

  /// The embed's description.
  String description;

  /// The embed's title.
  String title;

  /// The embed's thumbnail, if any.
  EmbedThumbnail thumbnail;

  /// The embed's provider, if any.
  EmbedProvider provider;

  Embed(Map data) {
    this.url = data['url'];
    this.type = data['type'];
    this.description = data['description'];

    if (data.containsKey('thumbnail')) {
      this.thumbnail = new EmbedThumbnail(data['thumbnail']);
    }
    if (data.containsKey('provider')) {
      this.provider = new EmbedProvider(data['provider']);
    }
  }
}
