import 'package:nyxx/src/models/guild/guild.dart';

class GuildPreview extends PartialGuild {
  final String name;

  final String? iconHash;

  final String? splashHash;

  final String? discoverySplashHash;

  // TODO
  //final List<Emoji> emojis;

  final GuildFeatures features;

  final int approximateMemberCount;

  final int approximatePresenceCount;

  final String? description;
  // TODO
  //final List<Sticker> stickers;

  GuildPreview({
    required super.id,
    required super.manager,
    required this.name,
    required this.iconHash,
    required this.splashHash,
    required this.discoverySplashHash,
    required this.features,
    required this.approximateMemberCount,
    required this.approximatePresenceCount,
    required this.description,
  });
}
