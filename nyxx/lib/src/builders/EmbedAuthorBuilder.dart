part of nyxx;

/// Build new instance of author which can be used in [EmbedBuilder]
class EmbedAuthorBuilder implements Builder {
  /// Author name
  String? name;

  /// Author url
  String? url;

  /// Author icon url
  String? iconUrl;

  int? get length => name?.length;

  @override

  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    if(this.name == null || this.name!.isEmpty) {
      throw new Exception("Author name cannot be null or empty");
    }

    if (this.length! > 256) {
      throw new Exception("Author name is too long. (256 characters limit)");
    }

    Map<String, dynamic> tmp = Map();

    tmp["name"] = name;
    if (url != null) tmp["url"] = url;
    if (iconUrl != null) tmp["icon_url"] = iconUrl;

    return tmp;
  }
}
