import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/emoji.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IBaseGuildEmoji implements SnowflakeEntity, IEmoji {
  /// True if emoji is partial.
  bool get isPartial;

  /// Returns cdn url to emoji
  String get cdnUrl;

  /// The name of the emoji.
  String get name;

  /// Creates partial emoji from given String or Snowflake.
  factory IBaseGuildEmoji.fromId(Snowflake id) => GuildEmojiPartial(id);

  /// Resolves this [GuildEmojiPartial] to [GuildEmoji].
  IGuildEmoji? resolve();
}

abstract class BaseGuildEmoji extends SnowflakeEntity implements IBaseGuildEmoji {
  /// Reference to [NyxxWebsocket]
  INyxx? get client;

  /// True if emoji is partial.
  @override
  bool get isPartial;

  /// Returns cdn url to emoji
  @override
  String get cdnUrl => "https://cdn.discordapp.com/emojis/$id.png";

  /// The name of the emoji.
  @override
  String get name;

  /// Creates an instance of [BaseGuildEmoji]
  BaseGuildEmoji(RawApiMap raw) : super(Snowflake(raw["id"]));

  @override
  String formatForMessage() => "<:$name:$id>";

  @override
  String encodeForAPI() => '$name:$id';

  /// Returns encoded string ready to send via message.
  @override
  String toString() => formatForMessage();

  /// Resolves this [GuildEmojiPartial] to [GuildEmoji]
  @override
  IGuildEmoji? resolve();
}

abstract class IGuildEmojiPartial implements IBaseGuildEmoji {}

class GuildEmojiPartial extends BaseGuildEmoji implements IGuildEmojiPartial {
  /// Reference to [INyxxWebsocket]
  @override
  INyxx? client;

  @override
  bool get isPartial => true;

  // If name is not avaliable; works for static emojis
  @override
  String get name => "nyxx";

  /// Creates an instance of [GuildEmojiPartial]
  GuildEmojiPartial(Snowflake id, [INyxx? clientInstance]) : super({"id": id.toString()}) {
    client = clientInstance;
  }

  /// Resolves this [GuildEmojiPartial] to [GuildEmoji]
  @override
  IGuildEmoji? resolve() {
    if (client != null) {
      return client!.emojis[Snowflake(id)];
    }
    return null;
  }
}

abstract class IGuildEmoji implements IBaseGuildEmoji {
  /// Reference to client
  INyxx get client;

  /// Reference to guild where emoji belongs to
  Cacheable<Snowflake, IGuild> get guild;

  /// Roles which can use this emote
  Iterable<Cacheable<Snowflake, IRole>> get roles;

  /// whether this emoji must be wrapped in colons
  bool get requireColons;

  /// whether this emoji is managed
  bool get managed;

  /// whether this emoji is animated
  bool get animated;

  /// The user that created this emoji, not present if [fetchCreator] was not called
  Cacheable<Snowflake, IUser>? get creator;

  /// Fetches the creator of this emoji
  Future<IUser> fetchCreator();

  /// Allows to delete guild emoji
  Future<void> delete();

  /// Allows to edit guild emoji
  Future<void> edit({String? name, List<Snowflake>? roles});
}

class GuildEmoji extends BaseGuildEmoji implements IGuildEmoji {
  /// Reference to client
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

  @override
  bool get isPartial => false;

  /// Returns cdn url to emoji
  @override
  String get cdnUrl => "https://cdn.discordapp.com/emojis/$id.${animated ? "gif" : "png"}";

  /// The user that created this emoji, not present if [fetchCreator] has not been called
  @override
  late Cacheable<Snowflake, IUser>? creator;

  @override
  String formatForMessage() => "<${animated ? 'a' : ''}:$name:$id>";

  /// Creates an instance of [GuildEmoji]
  GuildEmoji(this.client, RawApiMap raw, Snowflake guildId) : super(raw) {
    guild = GuildCacheable(client, guildId);

    name = raw["name"] as String;
    requireColons = raw["require_colons"] as bool? ?? false;
    managed = raw["managed"] as bool? ?? false;
    animated = raw["animated"] as bool? ?? false;
    roles = [for (final roleId in raw["roles"]) RoleCacheable(client, Snowflake(roleId), guild)];
  }

  /// Fetches the creator of this emoji
  @override
  Future<IUser> fetchCreator() => client.httpEndpoints.fetchEmojiCreator(guild.id, id);


  /// Resolve this emoji to [GuildEmoji]
  @override
  IGuildEmoji resolve() => this;

  /// Allows to delete guild emoji
  @override
  Future<void> delete() => client.httpEndpoints.deleteGuildEmoji(guild.id, id);

  /// Allows to edit guild emoji
  @override
  Future<void> edit({String? name, List<Snowflake>? roles}) => client.httpEndpoints.editGuildEmoji(guild.id, id, name: name, roles: roles);
}
