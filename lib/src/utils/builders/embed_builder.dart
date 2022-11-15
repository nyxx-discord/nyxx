import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/internal/exceptions/embed_builder_argument_exception.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/utils/builders/embed_author_builder.dart';
import 'package:nyxx/src/utils/builders/embed_field_builder.dart';
import 'package:nyxx/src/utils/builders/embed_footer_builder.dart';

/// Builds up embed object.
class EmbedBuilder extends Builder {
  /// Embed title
  String? title;

  /// Embed type
  String? type;

  /// Embed description.
  String? description;

  /// Url of Embed
  String? url;

  /// Color code of the embed
  DiscordColor? color;

  /// Timestamp of embed content
  DateTime? timestamp;

  /// Embed Footer
  EmbedFooterBuilder? footer;

  /// Image Url
  String? imageUrl;

  /// Thumbnail Url
  String? thumbnailUrl;

  /// Author of embed
  EmbedAuthorBuilder? author;

  /// Embed custom fields;
  late List<EmbedFieldBuilder> fields;

  /// Creates clean instance [EmbedBuilder]
  EmbedBuilder({
    this.author,
    this.color,
    this.description,
    this.fields = const [],
    this.footer,
    this.imageUrl,
    this.thumbnailUrl,
    this.timestamp,
    this.title,
    this.type,
    this.url,
  }) {
    fields = [];
  }

  /// Adds author to embed.
  void addAuthor(void Function(EmbedAuthorBuilder author) builder) {
    author = EmbedAuthorBuilder();
    builder(author!);
  }

  /// Adds footer to embed
  void addFooter(void Function(EmbedFooterBuilder footer) builder) {
    footer = EmbedFooterBuilder();
    builder(footer!);
  }

  /// Adds field to embed. [name] and [content] fields are required. Inline is set to false by default.
  void addField({dynamic name, dynamic content, bool inline = false, Function(EmbedFieldBuilder field)? builder, EmbedFieldBuilder? field}) {
    fields.add(_constructEmbedFieldBuilder(name: name, content: content, builder: builder, field: field, inline: inline));
  }

  /// Replaces field where [name] witch provided new field.
  void replaceField({dynamic name, dynamic content, bool inline = false, Function(EmbedFieldBuilder field)? builder, EmbedFieldBuilder? field}) {
    final index = fields.indexWhere((element) => element.name == name);
    fields[index] = _constructEmbedFieldBuilder(name: name, content: content, builder: builder, field: field, inline: inline);
  }

  EmbedFieldBuilder _constructEmbedFieldBuilder(
      {dynamic name, dynamic content, bool inline = false, Function(EmbedFieldBuilder field)? builder, EmbedFieldBuilder? field}) {
    if (field != null) {
      return field;
    }

    if (builder != null) {
      final tmp = EmbedFieldBuilder();
      builder(tmp);
      return tmp;
    }

    return EmbedFieldBuilder(name, content, inline);
  }

  /// Total length of all text fields of embed
  int get length =>
      (title?.length ?? 0) +
      (description?.length ?? 0) +
      (footer?.length ?? 0) +
      (author?.length ?? 0) +
      (fields.isEmpty ? 0 : fields.map((embed) => embed.length).reduce((f, s) => f + s));

  @override

  /// Builds object to Map() instance;
  RawApiMap build() {
    if (title != null && title!.length > 256) {
      throw EmbedBuilderArgumentException("Embed title is too long (256 characters limit)");
    }

    if (description != null && description!.length > 2048) {
      throw EmbedBuilderArgumentException("Embed description is too long (2048 characters limit)");
    }

    if (fields.length > 25) {
      throw EmbedBuilderArgumentException("Embed cannot contain more than 25 fields");
    }

    if (length > 6000) {
      throw EmbedBuilderArgumentException("Total length of embed cannot exceed 6000 characters");
    }

    return <String, dynamic>{
      if (title != null) "title": title,
      if (type != null) "type": type,
      if (description != null) "description": description,
      if (url != null) "url": url,
      if (timestamp != null) "timestamp": timestamp!.toUtc().toIso8601String(),
      if (color != null) "color": color!.value,
      if (footer != null) "footer": footer!.build(),
      if (imageUrl != null) "image": <String, dynamic>{"url": imageUrl},
      if (thumbnailUrl != null) "thumbnail": <String, dynamic>{"url": thumbnailUrl},
      if (author != null) "author": author!.build(),
      if (fields.isNotEmpty) "fields": fields.map((builder) => builder.build()).toList()
    };
  }
}
