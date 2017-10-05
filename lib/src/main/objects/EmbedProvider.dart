part of discord;

/// A message embed provider.
class EmbedProvider {
  /// The [Client] object.
  Client client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The embed provider's name.
  String name;

  /// The embed provider's URL.
  String url;

  EmbedProvider._new(this.client, this.raw) {
    this.name = raw['name'];
    this.url = raw['url'];
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.name;
  }
}
