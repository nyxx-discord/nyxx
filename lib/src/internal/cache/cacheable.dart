import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/core/user/user.dart';

/// Wraps [SnowflakeEntity] that can be taken from cache or optionally downloaded from API.
/// Always provides [id] of entity. `download()` method tries to get entity from API and returns it upon success or
/// throws Error if something happens in the process.
abstract class Cacheable<T extends Snowflake, S extends SnowflakeEntity> {
  final INyxx client;

  /// Id of entity
  final T id;

  Cacheable(this.client, this.id);

  /// Returns entity from cache or null if not present
  S? getFromCache();

  /// Downloads entity from cache and caches result
  Future<S> download();

  /// Returns entity from cache or tries to download from API if not found.
  /// If downloading is successful it caches results
  FutureOr<S> getOrDownload() async {
    final cacheResult = getFromCache();

    if (cacheResult != null) {
      return cacheResult;
    }

    return download();
  }

  @override
  bool operator ==(Object other) => other is Cacheable && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class RoleCacheable extends Cacheable<Snowflake, IRole> {
  final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [RoleCacheable]
  RoleCacheable(INyxx client, Snowflake id, this.guild) : super(client, id);

  @override
  Future<IRole> download() async => _fetchGuildRole();

  @override
  IRole? getFromCache() {
    final guildInstance = guild.getFromCache();

    if (guildInstance == null) {
      return null;
    }

    return guildInstance.roles[id];
  }

  // We cant download single role
  Future<IRole> _fetchGuildRole() async {
    final roles = await client.httpEndpoints.fetchGuildRoles(guild.id).toList();

    final guildCacheable = client.guilds[guild.id];
    if (guildCacheable != null) {
      guildCacheable.roles.clear();

      guildCacheable.roles.addEntries(roles.map((e) => MapEntry(e.id, e)));
    }

    try {
      return roles.firstWhere((element) => element.id == id);
    } on Error {
      throw ArgumentError("Cannot fetch role with id `$id` in guild with id `${guild.id}`");
    }
  }
}

class ChannelCacheable<T extends IChannel> extends Cacheable<Snowflake, T> {
  /// Creates an instance of [ChannelCacheable]
  ChannelCacheable(INyxx client, Snowflake id) : super(client, id);

  @override
  T? getFromCache() => client.channels[id] as T?;

  @override
  Future<T> download() => client.httpEndpoints.fetchChannel<T>(id);
}

class GuildCacheable extends Cacheable<Snowflake, IGuild> {
  GuildCacheable(INyxx client, Snowflake id) : super(client, id);

  @override
  IGuild? getFromCache() => client.guilds[id];

  @override
  Future<IGuild> download() => client.httpEndpoints.fetchGuild(id);
}

class UserCacheable extends Cacheable<Snowflake, IUser> {
  /// Creates an instance of [ChannelCacheable]
  UserCacheable(INyxx client, Snowflake id) : super(client, id);

  @override
  Future<IUser> download() => client.httpEndpoints.fetchUser(id);

  @override
  IUser? getFromCache() => client.users[id];
}

class MemberCacheable extends Cacheable<Snowflake, IMember> {
  final Cacheable<Snowflake, IGuild> guild;

  /// Creates an instance of [ChannelCacheable]
  MemberCacheable(INyxx client, Snowflake id, this.guild) : super(client, id);

  @override
  Future<IMember> download() => client.httpEndpoints.fetchGuildMember(guild.id, id);

  @override
  IMember? getFromCache() {
    final guildInstance = guild.getFromCache();

    if (guildInstance != null) {
      return guildInstance.members[id];
    }

    return null;
  }
}

class MessageCacheable<U extends ITextChannel> extends Cacheable<Snowflake, IMessage> {
  final Cacheable<Snowflake, U> channel;

  /// Creates an instance of [ChannelCacheable]
  MessageCacheable(INyxx client, Snowflake id, this.channel) : super(client, id);

  @override
  Future<IMessage> download() async {
    final channelInstance = await channel.getOrDownload();
    return channelInstance.fetchMessage(id);
  }

  @override
  IMessage? getFromCache() {
    final channelInstance = channel.getFromCache();

    if (channelInstance != null) {
      return channelInstance.messageCache[id];
    }

    return null;
  }
}
