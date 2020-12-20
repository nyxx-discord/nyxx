part of nyxx;

/// Cache Utility is a Utility that lets you retrieve Entities (from the cache) from outside of the nyxx project. Typically used in nyxx.* projects.
/// An example getting a user is below:
/// ```dart
/// void main() {
///     var bot = Nyxx("TOKEN");
///     Cacheable<Snowflake, User> cachedUser = CacheUtility.users(bot, Snowflake(''));
/// }
/// ```
class CacheUtility {
  /// Retrieves a cached User.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, User> cachedUser = CacheUtility.users(bot, Snowflake(''));
  /// }
  /// ```
  Cacheable<Snowflake, User> users(
    Nyxx client,
    Snowflake id,
  ) =>
      _UserCacheable(
        client,
        id,
      );

  /// Retrieves a cached Guild.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, Guild> cachedGuild = CacheUtility.guilds(bot, Snowflake(''));
  /// }
  /// ```
  Cacheable<Snowflake, Guild> guilds(
    Nyxx client,
    Snowflake id,
  ) =>
      _GuildCacheable(
        client,
        id,
      );

  /// Retrieves a cached Role.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, Guild> cachedGuild = CacheUtility.guilds(bot, Snowflake(''));
  ///     Cacheable<Snowflake, Role> cachedRole = CacheUtility.roles(bot, Snowflake(''), cachedGuild);
  /// }
  /// ```
  Cacheable<Snowflake, Role> roles(
    Nyxx client,
    Snowflake id,
    Cacheable<Snowflake, Guild> guild,
  ) =>
      _RoleCacheable(
        client,
        id,
        guild,
      );

  /// Retrieves a cached Role.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, IChannel> cachedChannel = CacheUtility.channels(bot, Snowflake(''));
  /// }
  /// ```
  Cacheable<Snowflake, IChannel> channels(
    Nyxx client,
    Snowflake id,
  ) =>
      _ChannelCacheable(client, id);

  /// Retrieves a cached Guild Member.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, Guild> cachedGuild = CacheUtility.guilds(bot, Snowflake(''));
  ///     Cacheable<Snowflake, Member> cachedMember = CacheUtility.members(bot, Snowflake(''), cachedGuild);
  /// }
  /// ```
  Cacheable<Snowflake, Member> members(
    Nyxx client,
    Snowflake id,
    Cacheable<Snowflake, Guild> guild,
  ) =>
      _MemberCacheable(
        client,
        id,
        guild,
      );

  /// Retrieves a cached Guild Member.
  /// ```dart
  /// void main() {
  ///     var bot = Nyxx("TOKEN");
  ///     Cacheable<Snowflake, TextChannel> cachedChannel = CacheUtility.channels(bot, Snowflake(''));
  ///     Cacheable<Snowflake, Member> cachedMember = CacheUtility.messages(bot, Snowflake(''), cachedChannel);
  /// }
  /// ```
  Cacheable<Snowflake, Message> messages(
    Nyxx client,
    Snowflake id,
    Cacheable<Snowflake, TextChannel> channel,
  ) =>
      _MessageCacheable(
        client,
        id,
        channel,
      );
}
