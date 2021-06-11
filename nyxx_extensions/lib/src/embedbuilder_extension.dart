import "package:nyxx/nyxx.dart";

/// Collection of extensions for [EmbedFieldBuilder]
extension EmbedFieldBuilderJson on EmbedFieldBuilder {
  /// Returns a [EmbedFieldBuilder] with data from the raw json
  EmbedFieldBuilder importJson(Map<String, dynamic> raw) {
    this.name = raw["name"];
    this.content = raw["value"];
    this.inline = raw["inline"] as bool?;
    return this;
  }
}

/// Collection of extensions for [EmbedFooterBuilder]
extension EmbedFooterBuilderJson on EmbedFooterBuilder {
  /// Returns a [EmbedFooterBuilder] with data from the raw json
  EmbedFooterBuilder importJson(Map<String, String?> raw) {
    this.text = raw["text"];
    this.iconUrl = raw["icon_url"];
    return this;
  }
}

/// Collection of extensions for [EmbedAuthorBuilder]
extension EmbedAuthorBuilderJson on EmbedAuthorBuilder {
  /// Returns a [EmbedAuthorBuilder] with data from the raw json
  EmbedAuthorBuilder importJson(Map<String, String?> raw) {
    this.name = raw["name"];
    this.url = raw["url"];
    this.iconUrl = raw["icon_url"];
    return this;
  }
}

/// Collection of extensions for [EmbedBuilder]
extension EmbedBuilderJson on EmbedBuilder {
  /// Returns a [EmbedBuilder] with data from the raw json
  EmbedBuilder importJson(Map<String, dynamic> raw) {
    this.title = raw["title"] as String?;
    this.description = raw["description"] as String?;
    this.url = raw["url"] as String?;
    this.color = raw["color"] != null ? DiscordColor.fromInt(raw["color"] as int) : null;
    this.timestamp = raw["timestamp"] != null ? DateTime.parse(raw["timestamp"] as String) : null;
    this.footer = raw["footer"] != null
        ? EmbedFooterBuilder().importJson(raw["footer"] as Map<String, String?>)
        : null;
    this.imageUrl = raw["image"]["url"] as String?;
    this.thumbnailUrl = raw["thumbnail"]["url"] as String?;
    this.author = raw["author"] != null
        ? EmbedAuthorBuilder().importJson(raw["author"] as Map<String, String?>)
        : null;

    for(final rawFields in raw["fields"] as List<dynamic>) {
      this.fields.add(EmbedFieldBuilder().importJson(rawFields as Map<String, dynamic>));
    }

    return this;
  }
}
