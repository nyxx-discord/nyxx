part of nyxx;

/// A message embed provider.
class EmbedProvider implements IEmbedProvider{
  /// The embed provider's name.
  late final String? name;

  /// The embed provider's URL.
  late final String? url;

  /// Creates an instance of [EmbedProvider]
  EmbedProvider(RawApiMap raw) {
    if (raw["name"] != null) {
      this.name = raw["name"] as String?;
    }

    if (raw["url"] != null) {
      this.url = raw["url"] as String?;
    }
  }
}
