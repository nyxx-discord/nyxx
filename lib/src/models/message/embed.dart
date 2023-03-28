import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class Embed {
  final String? title;

  final EmbedType type;

  final String? description;

  final Uri? url;

  final DateTime? timestamp;

  final DiscordColor? color;

  final EmbedFooter? footer;

  final EmbedImage? image;

  final EmbedThumbnail? thumbnail;

  final EmbedVideo? video;

  final EmbedProvider? provider;

  final EmbedAuthor? author;

  final List<EmbedField>? fields;

  Embed({
    required this.title,
    required this.type,
    required this.description,
    required this.url,
    required this.timestamp,
    required this.color,
    required this.footer,
    required this.image,
    required this.thumbnail,
    required this.video,
    required this.provider,
    required this.author,
    required this.fields,
  });
}

enum EmbedType {
  rich._('rich'),
  image._('image'),
  video._('video'),
  gif._('gifv'),
  article._('article'),
  link._('link');

  final String value;

  const EmbedType._(this.value);

  factory EmbedType.parse(String value) => EmbedType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown EmbedType', value),
      );

  @override
  String toString() => 'EmbedType($value)';
}

class EmbedFooter with ToStringHelper {
  final String text;

  final Uri? iconUrl;

  final Uri? proxiedIconUrl;

  EmbedFooter({
    required this.text,
    required this.iconUrl,
    required this.proxiedIconUrl,
  });
}

class EmbedImage with ToStringHelper {
  final Uri url;

  final Uri? proxiedUrl;

  final int? height;

  final int? width;

  EmbedImage({
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
  });
}

class EmbedThumbnail with ToStringHelper {
  final Uri url;

  final Uri? proxiedUrl;

  final int? height;

  final int? width;

  EmbedThumbnail({
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
  });
}

class EmbedVideo with ToStringHelper {
  final Uri? url;

  final Uri? proxiedUrl;

  final int? height;

  final int? width;

  EmbedVideo({
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
  });
}

class EmbedProvider with ToStringHelper {
  final String? name;

  final Uri? url;

  EmbedProvider({
    required this.name,
    required this.url,
  });
}

class EmbedAuthor with ToStringHelper {
  final String name;

  final Uri? url;

  final Uri? iconUrl;

  final Uri? proxyIconUrl;

  EmbedAuthor({
    required this.name,
    required this.url,
    required this.iconUrl,
    required this.proxyIconUrl,
  });
}

class EmbedField with ToStringHelper {
  final String name;

  final String value;

  final bool inline;

  EmbedField({
    required this.name,
    required this.value,
    required this.inline,
  });
}
