import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IBaseGuildEmoji implements SnowflakeEntity, IEmoji {
  /// Reference to [INyxx].
  INyxx get client;

  /// True if emoji is partial.
  bool get isPartial;

  /// The name of the emoji.
  String get name;

  /// Whether this emoji is animated.
  bool get animated;

  /// Creates partial emoji from given String or Snowflake.
  // TODO: Replace this
  factory IBaseGuildEmoji.fromId(Snowflake id) => GuildEmojiPartial({"id": id.toString()}, NyxxWebsocket('', 0));

  /// Returns cdn url to emoji
  String cdnUrl({String? format, int? size});
}

abstract class BaseGuildEmoji extends SnowflakeEntity implements IBaseGuildEmoji {
  @override
  final INyxx client;

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
  BaseGuildEmoji(RawApiMap raw, this.client) : super(Snowflake(raw["id"]));

  /// Returns cdn url to emoji
  @override
  String cdnUrl({String? format, int? size}) {
    return 'client.cdnHttpEndpoints';
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
  /// Resolves this [IResolvableGuildEmojiPartial] to [IGuildEmoji]
  IGuildEmoji resolve();
}

class GuildEmojiPartial extends BaseGuildEmoji implements IGuildEmojiPartial {
  @override
  final INyxx client;

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
  GuildEmojiPartial(RawApiMap raw, this.client) : super({"id": raw["id"]}, client) {
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
  ResolvableGuildEmojiPartial(RawApiMap raw, this.client) : super(raw, client) {
    name = raw["name"] as String? ?? "nyxx";
    animated = raw["animated"] as bool? ?? false;
  }

  /// Resolves this [IResolvableGuildEmojiPartial] to [IGuildEmoji]
  @override
  IGuildEmoji resolve() => client.guilds.values.expand((guild) => guild.emojis.values).firstWhere((emoji) => emoji.id == id) as IGuildEmoji;
}

abstract class IGuildEmoji implements IBaseGuildEmoji {
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
  GuildEmoji(INyxx client, RawApiMap raw, Snowflake guildId) : super(raw, client) {
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
