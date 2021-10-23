import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/guild/GuildFeature.dart';
import 'package:nyxx/src/core/message/GuildEmoji.dart';
import 'package:nyxx/src/internal/Constants.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IGuildPreview implements SnowflakeEntity {
  /// Reference to client
  INyxx get client;

  /// Guild name
  String get name;

  /// Hash of guild icon. To get url use [iconURL]
  String? get iconHash;

  /// Hash of guild spash image. To get url use [splashURL]
  String? get splashHash;

  /// Hash of guild discovery image. To get url use [discoveryURL]
  String? get discoveryHash;

  /// List of guild's emojis
  List<BaseGuildEmoji> get emojis;

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
  String? iconURL({String format = "webp", int size = 128});

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? splashURL({String format = "webp", int size = 128});

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  String? discoveryURL({String format = "webp", int size = 128});
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

  /// Hash of guild icon. To get url use [iconURL]
  @override
  String? iconHash;

  /// Hash of guild spash image. To get url use [splashURL]
  @override
  String? splashHash;

  /// Hash of guild discovery image. To get url use [discoveryURL]
  @override
  String? discoveryHash;

  /// List of guild's emojis
  @override
  late final List<GuildEmoji> emojis;

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
    this.name = raw["name"] as String;

    if (this.iconHash != null) {
      this.iconHash = raw["icon"] as String;
    }

    if (this.splashHash != null) {
      this.splashHash = raw["splash"] as String;
    }

    if (this.discoveryHash != null) {
      this.discoveryHash = raw["discovery_splash"] as String;
    }

    this.emojis = [for (var rawEmoji in raw["emojis"]) GuildEmoji(client, rawEmoji as RawApiMap, this.id)];

    this.features = (raw["features"] as List<dynamic>).map((e) => GuildFeature.from(e.toString()));

    this.approxMemberCount = raw["approximate_member_count"] as int;
    this.approxOnlineMembers = raw["approximate_presence_count"] as int;

    this.description = raw["description"] as String?;
  }

  /// The guild's icon, represented as URL.
  /// If guild doesn't have icon it returns null.
  @override
  String? iconURL({String format = "webp", int size = 128}) {
    if (this.iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/icons/$id/$iconHash.$format?size=$size";
    }

    return null;
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  @override
  String? splashURL({String format = "webp", int size = 128}) {
    if (this.splashHash != null) {
      return "https://cdn.${Constants.cdnHost}/splashes/$id/$splashHash.$format?size=$size";
    }

    return null;
  }

  /// URL to guild's splash.
  /// If guild doesn't have splash it returns null.
  @override
  String? discoveryURL({String format = "webp", int size = 128}) {
    if (this.discoveryHash != null) {
      return "https://cdn.${Constants.cdnHost}/discovery-splashes/$id/$discoveryHash.$format?size=$size";
    }

    return null;
  }
}
