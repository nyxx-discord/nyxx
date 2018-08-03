part of nyxx;

/// A message embed provider.
class EmbedProvider {
  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(this.raw) {
    if (raw['name'] != null) this.name = raw['name'] as String;

    if (raw['url'] != null) this.url = raw['url'] as String;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
