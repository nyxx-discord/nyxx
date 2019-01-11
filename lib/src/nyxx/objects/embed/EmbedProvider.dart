part of nyxx;

/// A message embed provider.
class EmbedProvider {
  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(Map<String, dynamic> raw) {
    if (raw['name'] != null) this.name = raw['name'] as String;

    if (raw['url'] != null) this.url = raw['url'] as String;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.name;

  @override
  int get hashCode => url.hashCode * 37 + name.hashCode;

  @override
  bool operator ==(other) => other is EmbedProvider
      ? other.url == this.url && other.name == this.name
      : false;
}
