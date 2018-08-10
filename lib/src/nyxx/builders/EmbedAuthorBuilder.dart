part of nyxx;

/// Build new instance of Author
class EmbedAuthorBuilder implements Builder {
  /// Author name
  String name;

  /// Author url
  String url;

  /// Author icon url
  String iconUrl;

  @override
  /// Builds object to Map() instance;
  Map<String, dynamic> _build() {
    Map<String, dynamic> tmp = new Map();

    if (name != null) tmp["name"] = name;
    if (url != null) tmp["url"] = url;
    if (iconUrl != null) tmp["icon_url"] = iconUrl;

    return tmp;
  }
}
