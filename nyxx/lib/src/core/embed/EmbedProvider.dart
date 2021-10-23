part of nyxx;

/// A message embed provider.
class EmbedProvider implements IEmbedProvider{
  /// The embed provider's name.
  @override
  late final String? name;

  /// The embed provider's URL.
  @override
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
