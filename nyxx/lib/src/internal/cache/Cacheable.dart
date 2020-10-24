part of nyxx;

abstract class Cacheable<T extends Snowflake, S extends SnowflakeEntity> {
  final Nyxx _client;

  /// Id of entity
  final T id;

  Cacheable._new(this._client, this.id);

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
  int get hashCode => super.hashCode;
}

class _RoleCacheable extends Cacheable<Snowflake, RoleNew> {
  final Cacheable<Snowflake, GuildNew> guild;

  _RoleCacheable(Nyxx client, Snowflake id, this.guild): super._new(client, id);

  @override
  Future<RoleNew> download() async => this._fetchGuildRole();

  @override
  RoleNew? getFromCache() {
    final guildInstance = guild.getFromCache();

    if (guildInstance == null) {
      return null;
    }

    return guildInstance.roles[this.id];
  }

  Future<RoleNew> _fetchGuildRole() async {
    final roles = await _client._httpEndpoints._fetchGuildRoles(this.id).toList();

    try {
      return roles.firstWhere((element) => element.id == this.id);
    } on Exception {
      throw ArgumentError("Cannot fetch role with id `${this.id}` in guild with id `${this.guild.id}`");
    }
  }
}

class _ChannelCacheable<T extends IChannel> extends Cacheable<Snowflake, T> {
  _ChannelCacheable(Nyxx client, Snowflake id): super._new(client, id);

  @override
  T? getFromCache() => this._client.channels[this.id] as T;

  @override
  Future<T> download() => _client._httpEndpoints._fetchChannel<T>(this.id);
}

class _GuildCacheable extends Cacheable<Snowflake, GuildNew> {
  _GuildCacheable(Nyxx client, Snowflake id): super._new(client, id);

  @override
  GuildNew? getFromCache() => this._client.guilds[this.id];

  @override
  Future<GuildNew> download() => _client._httpEndpoints._fetchGuild(this.id);
}

class _UserCacheable extends Cacheable<Snowflake, User> {
  _UserCacheable(Nyxx client, Snowflake id): super._new(client, id);

  @override
  Future<User> download() => _client._httpEndpoints._fetchUser(this.id);

  @override
  User? getFromCache() => this._client.users[this.id];
}

class _MemberCacheable extends Cacheable<Snowflake, Member> {
  final Cacheable<Snowflake, GuildNew> guild;

  _MemberCacheable(Nyxx client, Snowflake id, this.guild): super._new(client, id);

  @override
  Future<Member> download() =>
      this._client._httpEndpoints._fetchGuildMember(guild.id, id);

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

  _MessageCacheable(Nyxx client, Snowflake id, this.channel) : super._new(client, id);

  @override
  Future<Message> download() async {
    final channelInstance = await this.channel.getOrDownload();

    final message = await channelInstance.fetchMessage(this.id);

    if (message == null) {
      return Future.error(ArgumentError("Provided message id (${this.id}) does not belongs to given channel (${this.channel.id})"));
    }

    return message;
  }

  @override
  Message? getFromCache() {
    final channelInstance = this.channel.getFromCache();

    if (channelInstance != null) {
      return channelInstance.messageCache[this.id];
    }

    return null;
  }
}