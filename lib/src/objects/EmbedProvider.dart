part of discord;

/// A message embed provider.
class EmbedProvider {
  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(Map<String, dynamic> data) {
    this.name = data['name'];
    this.url = data['url'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
