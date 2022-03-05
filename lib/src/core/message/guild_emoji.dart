import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

abstract class IBaseGuildEmoji implements SnowflakeEntity, IEmoji {
  /// True if emoji is partial.
  bool get isPartial;

  /// The name of the emoji.
  String get name;

  /// Whether this emoji is animated.
  bool get animated;

  /// Creates partial emoji from given String or Snowflake.
  factory IBaseGuildEmoji.fromId(Snowflake id) => GuildEmojiPartial({"id": id.toString()});

  /// Returns cdn url to emoji
  String cdnUrl({String? format, int? size});
}

abstract class BaseGuildEmoji extends SnowflakeEntity implements IBaseGuildEmoji {
  /// True if emoji is partial.
  @override
  bool get isPartial;

  /// Whether this emoji is animated.
  @override
  bool get animated;

  /// The name of the emoji.
  @override
  String get name;

  /// Creates an instance of [BaseGuildEmoji]
  BaseGuildEmoji(RawApiMap raw) : super(Snowflake(raw["id"]));

  /// Returns cdn url to emoji
  @override
  String cdnUrl({String? format, int? size}) {
    var url = "${Constants.cdnUrl}/emojis/$id.";

    if (format == null) {
      if (animated) {
        url += "gif";
      } else {
        url += "webp";
      }
    } else {
      url += format;
    }

    if (size != null) {
      url += "?size=$size";
    }

    return url;
  }

  @override
  String formatForMessage() => "<${animated ? 'a' : ''}:$name:$id>";

  @override
  String encodeForAPI() => '$name:$id';

  /// Returns encoded string ready to send via message.
  @override
  String toString() => formatForMessage();
}

abstract class IGuildEmojiPartial implements IBaseGuildEmoji {}

abstract class IResolvableGuildEmojiPartial implements IGuildEmojiPartial {
  /// Reference to [INyxx]
  INyxx get client;

  /// Resolves this [IResolvableGuildEmojiPartial] to [IGuildEmoji]
  IGuildEmoji resolve();
}

class GuildEmojiPartial extends BaseGuildEmoji implements IGuildEmojiPartial {
  /// True if emoji is partial.
  @override
  bool get isPartial => true;

  /// The name of the emoji.
  @override
  late final String name;

  /// Whether this emoji is animated.
  @override
  late final bool animated;

  /// Creates an instance of [GuildEmojiPartial]
  GuildEmojiPartial(RawApiMap raw) : super({"id": raw["id"].toString()}) {
    name = raw["name"] as String? ?? "nyxx";
    animated = raw["animated"] as bool? ?? false;
  }
}

class ResolvableGuildEmojiPartial extends BaseGuildEmoji implements IResolvableGuildEmojiPartial {
  /// Whether this emoji is animated.
  @override
  late final bool animated;

  /// Reference to [INyxx]
  @override
  final INyxx client;

  /// Whether this emoji is partial.
  @override
  bool get isPartial => true;

  /// The name of the emoji.
  @override
  late final String name;

  /// Creates an instance of [ResolvableGuildEmojiPartial]
  ResolvableGuildEmojiPartial(RawApiMap raw, this.client) : super(raw) {
    name = raw["name"] as String? ?? "nyxx";
    animated = raw["animated"] as bool? ?? false;
  }

  /// Resolves this [IResolvableGuildEmojiPartial] to [IGuildEmoji]
  @override
  IGuildEmoji resolve() => client.guilds.values.expand((guild) => guild.emojis.values).firstWhere((emoji) => emoji.id == id) as IGuildEmoji;
}

abstract class IGuildEmoji implements IBaseGuildEmoji {
  /// Reference to [INyxx]
  INyxx get client;

  /// Reference to guild where emoji belongs to
  Cacheable<Snowflake, IGuild> get guild;

  /// Roles which can use this emote
  Iterable<Cacheable<Snowflake, IRole>> get roles;

  /// whether this emoji must be wrapped in colons
  bool get requireColons;

  /// whether this emoji is managed
  bool get managed;

  /// Fetches the creator of this emoji
  Future<IUser> fetchCreator();

  /// Allows to delete guild emoji
  Future<void> delete();

  /// Allows to edit guild emoji
  Future<void> edit({String? name, List<Snowflake>? roles});
}

class GuildEmoji extends BaseGuildEmoji implements IGuildEmoji {
  /// Reference to [INyxx]
  @override
  final INyxx client;

  /// Reference to guild where emoji belongs to
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Roles which can use this emote
  @override
  late final Iterable<Cacheable<Snowflake, IRole>> roles;

  /// whether this emoji must be wrapped in colons
  @override
  late final bool requireColons;

  /// whether this emoji is managed
  @override
  late final bool managed;

  /// whether this emoji is animated
  @override
  late final bool animated;

  /// The name of the emoji.
  @override
  late final String name;

  /// True if emoji is partial.
  @override
  bool get isPartial => false;

  /// Creates an instance of [GuildEmoji]
  GuildEmoji(this.client, RawApiMap raw, Snowflake guildId) : super(raw) {
    guild = GuildCacheable(client, guildId);

    name = raw["name"] as String;
    requireColons = raw["require_colons"] as bool? ?? false;
    managed = raw["managed"] as bool? ?? false;
    animated = raw["animated"] as bool? ?? false;
    roles = [for (final roleId in raw["roles"]) RoleCacheable(client, Snowflake(roleId), guild)];
  }

  /// Returns encoded emoji for usage in message
  @override
  String formatForMessage() => "<${animated ? 'a' : ''}:$name:$id>";

  /// Fetches the creator of this emoji
  @override
  Future<IUser> fetchCreator() => client.httpEndpoints.fetchEmojiCreator(guild.id, id);

  /// Allows to delete guild emoji
  @override
  Future<void> delete() => client.httpEndpoints.deleteGuildEmoji(guild.id, id);

  /// Allows to edit guild emoji
  @override
  Future<void> edit({String? name, List<Snowflake>? roles}) => client.httpEndpoints.editGuildEmoji(guild.id, id, name: name, roles: roles);
}
