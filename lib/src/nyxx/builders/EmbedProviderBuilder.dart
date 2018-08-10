part of nyxx;

/// Builds new instance of provider
class EmbedProviderBuilder implements Builder {
  /// Name of provider
  String name;

  /// Url of provider
  String url;

  @override
  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = new Map();

    if (name != null) tmp["name"] = name;
    if (url != null) tmp["url"] = url;

    return tmp;
  }
}
