import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/guild_emoji.dart';
import 'package:nyxx/src/core/message/sticker.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IGuildCreateEvent {
  /// The guild created.
  IGuild get guild;
}

/// Sent when the bot joins a guild.
class GuildCreateEvent implements IGuildCreateEvent {
  /// The guild created.
  @override
  late final IGuild guild;

  /// Creates na instance of [GuildCreateEvent]
  GuildCreateEvent(RawApiMap raw, INyxx client) {
    this.guild = Guild(client, raw["d"] as RawApiMap, true);
    client.guilds[guild.id] = guild;
  }
}

abstract class IGuildUpdateEvent {
  /// The guild after the update.
  IGuild get guild;
}

/// Sent when a guild is updated.
class GuildUpdateEvent implements IGuildUpdateEvent {
  /// The guild after the update.
  @override
  late final IGuild guild;

  /// Creates na instance of [GuildUpdateEvent]
  GuildUpdateEvent(RawApiMap json, INyxx client) {
    this.guild = Guild(client, json["d"] as RawApiMap);

    final oldGuild = client.guilds[this.guild.id];
    if (oldGuild != null) {
      this.guild.members.addAll(oldGuild.members);
    }

    client.guilds[guild.id] = guild;
  }
}

abstract class IGuildDeleteEvent {
  /// The guild.
  Cacheable<Snowflake, IGuild> get guild;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  bool get unavailable;
}

/// Sent when you leave a guild.
class GuildDeleteEvent implements IGuildDeleteEvent {
  /// The guild.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// True if guild is unavailable which means disconnected due discord side problems
  /// False if user was kicked from guild
  @override
  late final bool unavailable;

  /// Creates na instance of [GuildDeleteEvent]
  GuildDeleteEvent(RawApiMap raw, INyxx client) {
    this.unavailable = raw["d"]["unavailable"] as bool? ?? false;
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["id"]));

    client.guilds.remove(guild.id);
  }
}

abstract class IGuildMemberRemoveEvent {
  /// The guild the user left.
  Cacheable<Snowflake, IGuild> get guild;

  ///The user that left.
  IUser get user;
}

/// Sent when a user leaves a guild, can be a leave, kick, or ban.
class GuildMemberRemoveEvent implements IGuildMemberRemoveEvent {
  /// The guild the user left.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  ///The user that left.
  @override
  late final IUser user;

  /// Creates na instance of [GuildMemberRemoveEvent]
  GuildMemberRemoveEvent(RawApiMap json, INyxx client) {
    this.user = User(client, json["d"]["user"] as RawApiMap);
    this.guild = GuildCacheable(client, Snowflake(json["d"]["guild_id"]));

    final guildInstance = this.guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.members.remove(this.user.id);
    }
  }
}

abstract class IGuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  Cacheable<Snowflake, IMember> get member;

  /// User if user is updated. Will be null if member is not null.
  IUser get user;

  /// Guild in which member is
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a member is updated.
class GuildMemberUpdateEvent implements IGuildMemberUpdateEvent {
  /// The member after the update if member is updated.
  @override
  late final Cacheable<Snowflake, IMember> member;

  /// User if user is updated. Will be null if member is not null.
  @override
  late final IUser user;

  /// Guild in which member is
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [GuildMemberUpdateEvent]
  GuildMemberUpdateEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.member = MemberCacheable(client, Snowflake(raw["d"]["user"]["id"]), guild);

    final user = User(client, raw["d"]["user"] as RawApiMap);
    if (client.cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final memberInstance = this.member.getFromCache();
    if (memberInstance == null) {
      return;
    }

    final guildInstance = this.guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    final nickname = raw["d"]["nickname"] as String?;
    final roles = (raw["d"]["roles"] as RawApiList).map((str) => Snowflake(str)).toList();
    final boostingSince = DateTime.tryParse(raw["premium_since"] as String? ?? "");

    (memberInstance as Member).updateMember(nickname, roles, boostingSince);
  }
}

abstract class IGuildMemberAddEvent {
  /// The member that joined.
  late final IMember member;

  /// User object of member that joined
  late final IUser user;

  /// Guild where used was added
  late final Cacheable<Snowflake, IGuild> guild;
}

/// Sent when a member joins a guild.
class GuildMemberAddEvent implements IGuildMemberAddEvent {
  /// The member that joined.
  @override
  late final IMember member;

  /// User object of member that joined
  @override
  late final IUser user;

  /// Guild where used was added
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [GuildMemberAddEvent]
  GuildMemberAddEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.member = Member(client, raw["d"] as RawApiMap, this.guild.id);
    this.user = User(client, raw["d"]["user"] as RawApiMap);

    if (client.cacheOptions.userCachePolicyLocation.event) {
      client.users[user.id] = user;
    }

    final guildInstance = this.guild.getFromCache();
    if (guildInstance == null) {
      return;
    }

    if (client.cacheOptions.memberCachePolicyLocation.event && client.cacheOptions.memberCachePolicy.canCache(this.member)) {
      guildInstance.members[this.member.id] = member;
    }
  }
}

abstract class IGuildBanAddEvent {
  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;

  /// The user that was banned.
  IUser get user;
}

/// Sent when a member is banned.
class GuildBanAddEvent implements IGuildBanAddEvent {
  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The user that was banned.
  @override
  late final IUser user;

  /// Creates na instance of [GuildBanAddEvent]
  GuildBanAddEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.user = User(client, raw["d"]["user"] as RawApiMap);
  }
}

abstract class IGuildBanRemoveEvent {
  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;

  /// The user that was banned.
  IUser get user;
}

/// Sent when a user is unbanned from a guild.
class GuildBanRemoveEvent implements IGuildBanRemoveEvent {
  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The user that was banned.
  @override
  late final IUser user;

  /// Creates na instance of [GuildBanRemoveEvent]
  GuildBanRemoveEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.user = User(client, raw["d"]["user"] as RawApiMap);
  }
}

abstract class IGuildEmojisUpdateEvent {
  /// List of modified emojis
  List<IGuildEmoji> get emojis;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Fired when emojis are updated
class GuildEmojisUpdateEvent implements IGuildEmojisUpdateEvent {
  /// List of modified emojis
  @override
  late final List<IGuildEmoji> emojis = [];

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [GuildEmojisUpdateEvent]
  GuildEmojisUpdateEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    final guildInstance = this.guild.getFromCache();
    for (final rawEmoji in raw["d"]["emojis"]) {
      final emoji = GuildEmoji(client, rawEmoji as RawApiMap, this.guild.id);

      this.emojis.add(emoji);

      if (guildInstance != null) {
        guildInstance.emojis[emoji.id] = emoji;
      }
    }
  }
}

abstract class IRoleCreateEvent {
  /// The role that was created.
  IRole get role;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is created.
class RoleCreateEvent implements IRoleCreateEvent {
  /// The role that was created.
  @override
  late final IRole role;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [RoleCreateEvent]
  RoleCreateEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    this.role = Role(client, raw["d"]["role"] as RawApiMap, this.guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.roles[role.id] = role;
    }
  }
}

abstract class IRoleDeleteEvent {
  /// Id of tole that was deleted
  Cacheable<Snowflake, IRole>? get role;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is deleted.
class RoleDeleteEvent implements IRoleDeleteEvent {
  /// Id of tole that was deleted
  @override
  late final Cacheable<Snowflake, IRole>? role;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [RoleDeleteEvent]
  RoleDeleteEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      this.role = this.role = RoleCacheable(client, Snowflake(raw["d"]["role_id"]), guild);
      guildInstance.roles.remove(role!.id);
    } else {
      this.role = null;
    }
  }
}

abstract class IRoleUpdateEvent {
  /// The role after the update.
  IRole get role;

  /// The guild that the member was banned from.
  Cacheable<Snowflake, IGuild> get guild;
}

/// Sent when a role is updated.
class RoleUpdateEvent implements IRoleUpdateEvent {
  /// The role after the update.
  @override
  late final IRole role;

  /// The guild that the member was banned from.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Creates na instance of [RoleUpdateEvent]
  RoleUpdateEvent(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.role = Role(client, raw["d"]["role"] as RawApiMap, this.guild.id);

    final guildInstance = guild.getFromCache();
    if (guildInstance != null) {
      guildInstance.roles[role.id] = role;
    }
  }
}

abstract class IGuildStickerUpdate {
  /// Cacheable of guild where stickers changed
  Cacheable<Snowflake, IGuild> get guild;

  /// List of stickers
  List<IGuildSticker> get stickers;
}

/// Sent when a guild's stickers have been updated.
class GuildStickerUpdate implements IGuildStickerUpdate {
  /// Cacheable of guild where stickers changed
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// List of stickers
  @override
  late final List<IGuildSticker> stickers;

  /// Creates na instance of [GuildStickerUpdate]
  GuildStickerUpdate(RawApiMap raw, INyxx client) {
    this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    this.stickers = [for (final rawSticker in raw["d"]["stickers"]) GuildSticker(rawSticker as RawApiMap, client)];
  }
}
