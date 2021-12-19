import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/embed/embed_author.dart';
import 'package:nyxx/src/core/embed/embed_field.dart';
import 'package:nyxx/src/core/embed/embed_footer.dart';
import 'package:nyxx/src/core/embed/embed_provider.dart';
import 'package:nyxx/src/core/embed/embed_thumbnail.dart';
import 'package:nyxx/src/core/embed/embed_video.dart';
import 'package:nyxx/src/internal/interfaces/convertable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/embed_builder.dart';

abstract class IEmbed implements Convertable<EmbedBuilder> {
  /// The embed's title.
  String? get title;

  /// The embed's type
  String? get type;

  /// The embed's description.
  String? get description;

  /// The embed's URL
  String? get url;

  /// Timestamp of embed content
  DateTime? get timestamp;

  /// Color of embed
  DiscordColor? get color;

  /// Embed's footer
  IEmbedFooter? get footer;

  /// The embed's thumbnail, if any.
  IEmbedThumbnail? get thumbnail;

  /// The embed's provider, if any.
  IEmbedProvider? get provider;

  /// Embed image
  IEmbedThumbnail? get image;

  /// Embed video
  IEmbedVideo? get video;

  /// Embed author
  IEmbedAuthor? get author;

  /// Map of fields of embed. Map(name, field)
  List<IEmbedField> get fields;
}

/// A message embed.
/// Can contain null elements.
class Embed implements IEmbed {
  /// The embed's title.
  @override
  late final String? title;

  /// The embed's type
  @override
  late final String? type;

  /// The embed's description.
  @override
  late final String? description;

  /// The embed's URL
  @override
  late final String? url;

  /// Timestamp of embed content
  @override
  late final DateTime? timestamp;

  /// Color of embed
  @override
  late final DiscordColor? color;

  /// Embed's footer
  @override
  late final IEmbedFooter? footer;

  /// The embed's thumbnail, if any.
  @override
  late final IEmbedThumbnail? thumbnail;

  /// The embed's provider, if any.
  @override
  late final IEmbedProvider? provider;

  /// Embed image
  @override
  late final IEmbedThumbnail? image;

  /// Embed video
  @override
  late final IEmbedVideo? video;

  /// Embed author
  @override
  late final IEmbedAuthor? author;

  /// Map of fields of embed. Map(name, field)
  @override
  late final List<IEmbedField> fields;

  /// Creates an instance [Embed]
  Embed(RawApiMap raw) {
    if (raw["title"] != null) {
      title = raw["title"] as String;
    }

    if (raw["url"] != null) {
      url = raw["url"] as String;
    }

    if (raw["type"] != null) {
      type = raw["type"] as String;
    }

    if (raw["description"] != null) {
      description = raw["description"] as String;
    }

    if (raw["timestamp"] != null) {
      timestamp = DateTime.parse(raw["timestamp"] as String);
    }

    if (raw["color"] != null) {
      color = DiscordColor.fromInt(raw["color"] as int);
    }

    if (raw["author"] != null) {
      author = EmbedAuthor(raw["author"] as RawApiMap);
    }

    if (raw["video"] != null) {
      video = EmbedVideo(raw["video"] as RawApiMap);
    }

    if (raw["image"] != null) {
      image = EmbedThumbnail(raw["image"] as RawApiMap);
    }

    if (raw["footer"] != null) {
      footer = EmbedFooter(raw["footer"] as RawApiMap);
    }

    if (raw["thumbnail"] != null) {
      thumbnail = EmbedThumbnail(raw["thumbnail"] as RawApiMap);
    }

    if (raw["provider"] != null) {
      provider = EmbedProvider(raw["provider"] as RawApiMap);
    }

    fields = [
      if (raw["fields"] != null)
        for (var obj in raw["fields"]) EmbedField(obj as RawApiMap)
    ];
  }

  @override
  EmbedBuilder toBuilder() => EmbedBuilder()
    ..title = title
    ..type = type
    ..description = description
    ..url = url
    ..timestamp = timestamp
    ..color = color
    ..footer = footer?.toBuilder()
    ..thumbnailUrl = thumbnail?.url
    ..imageUrl = image?.url
    ..author = author?.toBuilder()
    ..fields = fields.map((field) => field.toBuilder()).toList();
}
