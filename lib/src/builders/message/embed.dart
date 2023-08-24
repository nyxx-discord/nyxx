import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/message/embed.dart';

class EmbedBuilder extends CreateBuilder<Embed> {
  String? title;

  String? description;

  Uri? url;

  DateTime? timestamp;

  DiscordColor? color;

  EmbedFooterBuilder? footer;

  EmbedImageBuilder? image;

  EmbedThumbnailBuilder? thumbnail;

  EmbedAuthorBuilder? author;

  List<EmbedFieldBuilder>? fields;

  EmbedBuilder({
    this.title,
    this.description,
    this.url,
    this.timestamp,
    this.color,
    this.footer,
    this.image,
    this.thumbnail,
    this.author,
    this.fields,
  });

  @override
  Map<String, Object?> build() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (url != null) 'url': url.toString(),
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (color != null) 'color': color!.value,
        if (footer != null) 'footer': footer!.build(),
        if (image != null) 'image': image!.build(),
        if (thumbnail != null) 'thumbnail': thumbnail!.build(),
        if (author != null) 'author': author!.build(),
        if (fields != null) 'fields': fields!.map((e) => e.build()).toList(),
      };
}

class EmbedFooterBuilder extends CreateBuilder<EmbedFooter> {
  String text;

  Uri? iconUrl;

  EmbedFooterBuilder({required this.text, this.iconUrl});

  @override
  Map<String, Object?> build() => {
        'text': text,
        if (iconUrl != null) 'icon_url': iconUrl!.toString(),
      };
}

class EmbedImageBuilder extends CreateBuilder<EmbedImage> {
  Uri url;

  EmbedImageBuilder({required this.url});

  @override
  Map<String, Object?> build() => {
        'url': url.toString(),
      };
}

class EmbedThumbnailBuilder extends CreateBuilder<EmbedThumbnail> {
  Uri url;

  EmbedThumbnailBuilder({required this.url});

  @override
  Map<String, Object?> build() => {
        'url': url.toString(),
      };
}

class EmbedAuthorBuilder extends CreateBuilder<EmbedAuthor> {
  String name;

  Uri? url;

  Uri? iconUrl;

  EmbedAuthorBuilder({required this.name, this.url, this.iconUrl});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (url != null) 'url': url!.toString(),
        if (iconUrl != null) 'icon_url': iconUrl!.toString(),
      };
}

class EmbedFieldBuilder extends CreateBuilder<EmbedField> {
  String name;

  String value;

  bool isInline;

  EmbedFieldBuilder({
    required this.name,
    required this.value,
    required this.isInline,
  });

  @override
  Map<String, Object?> build() => {
        'name': name,
        'value': value,
        'inline': isInline,
      };
}
