import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/guild/guild_feature.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IGuildPreview implements SnowflakeEntity {
  /// Reference to client
  INyxx get client;

  /// Guild name
  String get name;

  /// Hash of guild icon. To get url use [iconUrl]
  String? get iconHash;

  /// Hash of guild spash image. To get url use [splashUrl]
  String? get splashHash;

  /// Hash of guild discovery image. To get url use [discoveryUrl]
  String? get discoveryHash;

  /// List of guild's emojis
  List<IBaseGuildEmoji> get emojis;

  /// List of guild's features
  Iterable<GuildFeature> get features;

  /// Approximate number of members in this guild
  int get approxMemberCount;

  /// Approximate number of online members in this guild
  int get approxOnlineMembers;

  /// The description for the guild
  String? get description;

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  String? iconUrl({String format = 'webp', int? size, bool? animated});

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashUrl({String format = 'webp', int? size});

  /// URL to guild's splash.
  /// If guild doesn't have discovery it returns null.
  String? discoveryUrl({String format = 'webp', int? size});
}

/// Returns guild  even if the user is not in the guild.
/// This endpoint is only for Public guilds.
class GuildPreview extends SnowflakeEntity implements IGuildPreview {
  /// Reference to client
  @override
  final INyxx client;

  /// Guild name
  @override
  late final String name;

  /// Hash of guild icon. To get url use [iconUrl]
  @override
  String? iconHash;

  /// Hash of guild spash image. To get url use [splashUrl]
  @override
  String? splashHash;

  /// Hash of guild discovery image. To get url use [discoveryUrl]
  @override
  String? discoveryHash;

  /// List of guild's emojis
  @override
  late final List<IGuildEmoji> emojis;

  /// List of guild's features
  @override
  late final Iterable<GuildFeature> features;

  /// Approximate number of members in this guild
  @override
  late final int approxMemberCount;

  /// Approximate number of online members in this guild
  @override
  late final int approxOnlineMembers;

  /// The description for the guild
  @override
  String? description;

  /// Creates an instance of [GuildPreview]
  GuildPreview(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    name = raw["name"] as String;

    iconHash = raw["icon"] as String?;

    splashHash = raw["splash"] as String?;

    discoveryHash = raw["discovery_splash"] as String?;

    emojis = [for (final rawEmoji in raw["emojis"] as RawApiList) GuildEmoji(client, rawEmoji as RawApiMap, id)];

    features = (raw["features"] as RawApiList).map((e) => GuildFeature.from(e.toString()));

    approxMemberCount = raw["approximate_member_count"] as int;
    approxOnlineMembers = raw["approximate_presence_count"] as int;

    description = raw["description"] as String?;
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  @override
  String? iconUrl({String format = 'webp', int? size, bool? animated}) {
    if (iconHash == null) {
      return null;
    }

    animated ??= iconHash?.startsWith("a_") ?? false;

    return client.cdnHttpEndpoints.icon(id, iconHash!, format: format, size: size, animated: animated);
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  @override
  String? splashUrl({String format = 'webp', int? size}) {
    if (splashHash == null) {
      return null;
    }

    return client.cdnHttpEndpoints.splash(id, splashHash!, format: format, size: size);
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  @override
  String? discoveryUrl({String format = 'webp', int? size}) {
    if (discoveryHash == null) {
      return null;
    }

    return client.cdnHttpEndpoints.discoverySplash(id, discoveryHash!, format: format, size: size);
  }
}
