part of nyxx;

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
    final cacheResult = this.getFromCache();

    if (cacheResult != null) {
      return cacheResult;
    }

    return this.download();
  }

  @override
  bool operator ==(Object other) => other is Cacheable && other.id == this.id;

  @override
  int get hashCode => id.hashCode;
}

class _RoleCacheable extends Cacheable<Snowflake, Role> {
  final Cacheable<Snowflake, Guild> guild;

  _RoleCacheable(INyxx client, Snowflake id, this.guild): super._new(client, id);

  @override
  Future<IRole> download() async => this._fetchGuildRole();

  @override
  IRole? getFromCache() {
    final guildInstance = guild.getFromCache();

    if (guildInstance == null) {
      return null;
    }

    return guildInstance.roles[this.id];
  }

  // We cant download single role
  Future<IRole> _fetchGuildRole() async {
    final roles = await client.httpEndpoints.fetchGuildRoles(this.id).toList();

    try {
      return roles.firstWhere((element) => element.id == this.id);
    } on Exception {
      throw ArgumentError("Cannot fetch role with id `${this.id}` in guild with id `${this.guild.id}`");
    }
  }
}

class _ChannelCacheable<T extends IChannel> extends Cacheable<Snowflake, T> {
  _ChannelCacheable(INyxx client, Snowflake id): super._new(client, id);

  @override
  T? getFromCache() => this.client.channels[this.id] as T?;

  @override
  Future<T> download() => client.httpEndpoints.fetchChannel<T>(this.id);
}

class GuildCacheable extends Cacheable<Snowflake, IGuild> {
  GuildCacheable(INyxx client, Snowflake id): super(client, id);

  @override
  IGuild? getFromCache() => this.client.guilds[this.id];

  @override
  Future<IGuild> download() => client.httpEndpoints.fetchGuild(this.id);
}

class _UserCacheable extends Cacheable<Snowflake, User> {
  _UserCacheable(INyxx client, Snowflake id): super._new(client, id);

  @override
  Future<User> download() => _client.httpEndpoints.fetchUser(this.id);

  @override
  IUser? getFromCache() => this.client.users[this.id];
}

class _MemberCacheable extends Cacheable<Snowflake, Member> {
  final Cacheable<Snowflake, Guild> guild;

  _MemberCacheable(INyxx client, Snowflake id, this.guild): super._new(client, id);

  @override
  Future<Member> download() =>
      this._client.httpEndpoints.fetchGuildMember(guild.id, id);

  @override
  Member? getFromCache() {
    final guildInstance = this.guild.getFromCache();

    if (guildInstance != null) {
      return guildInstance.members[this.id];
    }

    return null;
  }
}

class _MessageCacheable<U extends TextChannel> extends Cacheable<Snowflake, Message> {
  final Cacheable<Snowflake, U> channel;

  _MessageCacheable(INyxx client, Snowflake id, this.channel) : super._new(client, id);

  @override
  Future<IMessage> download() async {
    final channelInstance = await this.channel.getOrDownload();
    return channelInstance.fetchMessage(this.id);
  }

  @override
  IMessage? getFromCache() {
    final channelInstance = this.channel.getFromCache();

    if (channelInstance != null) {
      return channelInstance.messageCache[this.id];
    }

    return null;
  }
}
