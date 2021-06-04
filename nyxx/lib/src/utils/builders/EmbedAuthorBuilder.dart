part of nyxx;

/// Build new instance of author which can be used in [EmbedBuilder]
class EmbedAuthorBuilder extends Builder {
  /// Author name
  String? name;

  /// Author url
  String? url;

  /// Author icon url
  String? iconUrl;

  /// Returns length of embeds author section
  int? get length => name?.length;

  /// Create empty [EmbedAuthorBuilder]
  EmbedAuthorBuilder();

  EmbedAuthorBuilder.fromJson(Map<String, String?> raw) {
    this.name = raw["name"];
    this.url = raw["url"];
    this.iconUrl = raw["icon_url"];
  }

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> build() {
    if (this.name == null || this.name!.isEmpty) {
      throw EmbedBuilderArgumentException._new("Author name cannot be null or empty");
    }

    if (this.length! > 256) {
      throw EmbedBuilderArgumentException._new("Author name is too long. (256 characters limit)");
    }

    return <String, dynamic> {
      "name": name,
      if (url != null) "url": url,
      if (iconUrl != null) "icon_url": iconUrl
    };
  }
}
