import '../../objects.dart';

/// A message embed provider.
class EmbedProvider {
  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider(Map data) {
    this.name = data['name'];
    this.url = data['url'];
  }
}
