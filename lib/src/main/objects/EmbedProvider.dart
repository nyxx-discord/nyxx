part of discord;

/// A message embed provider.
class EmbedProvider {
  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(this.raw) {
    this.name = raw['name'];
    this.url = raw['url'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
