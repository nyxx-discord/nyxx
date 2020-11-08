part of nyxx;

/// Predicate which will decide if entity could be cached
typedef CachePolicyPredicate<T extends SnowflakeEntity> = bool Function(T);

/// Describes in which places entity should be cached
class CachePolicyLocation {
  /// Allows entities to be cached inside events
  bool event = true;

  /// Allows entities to be cached inside other entities constructors, eg. member object inside message
  bool objectConstructor = false;

  /// Allows entities to be cached in other places
  bool other = false;

  /// Allows entities downloaded from http api to be cached
  bool http = true;

  /// Default options.
  /// [event] and [http] will be enabled by default
  CachePolicyLocation();

  /// Enables all cache locations
  CachePolicyLocation.all() {
    this.event = true;
    this.objectConstructor = true;
    this.other = true;
    this.http = true;
  }

  /// Disabled all cache locations
  CachePolicyLocation.none() {
    this.event = false;
    this.objectConstructor = false;
    this.other = false;
    this.http = false;
  }
}

/// CachePolicy is set of rules which will decide if entity should be cached.
class CachePolicy<T extends SnowflakeEntity> {
  final CachePolicyPredicate<T> _predicate;

  /// Constructor
  CachePolicy(this._predicate);

  /// Pure function which will decide based on given predicate if [entity] will be cached
  bool canCache(T entity) => _predicate(entity);

  /// Convenience method to concatenate other policy
  CachePolicy<T> or(CachePolicy<T> other) =>
      CachePolicy((entity) => this.canCache(entity) || other.canCache(entity));

  /// Convenience method to require other policy
  CachePolicy<T> and(CachePolicy<T> other) =>
      CachePolicy((entity) => this.canCache(entity) && other.canCache(entity));

  /// Composes a policy by concatenating multiple other policies from list
  static CachePolicy<S> any<S extends SnowflakeEntity>(List<CachePolicy<S>> policies) =>
      CachePolicy((entity) => policies.any((policy) => policy.canCache(entity)));
}

/// Cache policies for caching members
class MemberCachePolicy extends CachePolicy<Member> {
  /// Do not cache members
  static final CachePolicy<Member> none = MemberCachePolicy((member) => false);

  /// Cache all members
  static final CachePolicy<Member> all = MemberCachePolicy((member) => true);

  /// Cache members which have online status
  static final CachePolicy<Member> online = MemberCachePolicy((member) => member.user.getFromCache()?.status?.isOnline ?? false);

  /// Cache only members which have voice state not null
  static final CachePolicy<Member> voice = MemberCachePolicy((member) => member.voiceState != null);

  /// Cache only member which are owner of guild
  static final CachePolicy<Member> owner = MemberCachePolicy((member) => member.guild.getFromCache()?.owner?.id == member.id);

  /// Default policy is [owner] or [voice]. So it caches guild owners and users in voice channels
  static final CachePolicy<Member> def = owner.or(voice);

  /// Constructor
  MemberCachePolicy(CachePolicyPredicate<Member> predicate) : super(predicate);
}

/// Cache policies for caching channels
class ChannelCachePolicy extends CachePolicy<IChannel> {
  /// Do not cache channels
  static final CachePolicy<IChannel> none = ChannelCachePolicy((channel) => false);

  /// Cache all channels
  static final CachePolicy<IChannel> all = ChannelCachePolicy((channel) => true);

  /// Cache only voice channels
  static final CachePolicy<IChannel> voice = ChannelCachePolicy((channel) => channel is VoiceGuildChannel);

  /// Cache only text channels
  static final CachePolicy<IChannel> text = ChannelCachePolicy((channel) => channel is TextChannel);

  /// Default policy is [all]
  static final CachePolicy<IChannel> def = all;

  /// Constructor
  ChannelCachePolicy(CachePolicyPredicate<IChannel> predicate) : super(predicate);
}
