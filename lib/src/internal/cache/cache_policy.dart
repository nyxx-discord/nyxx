import 'package:nyxx/nyxx.dart';

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
    event = true;
    objectConstructor = true;
    other = true;
    http = true;
  }

  /// Disabled all cache locations
  CachePolicyLocation.none() {
    event = false;
    objectConstructor = false;
    other = false;
    http = false;
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
  CachePolicy<T> or(CachePolicy<T> other) => CachePolicy((entity) => canCache(entity) || other.canCache(entity));

  /// Convenience method to require other policy
  CachePolicy<T> and(CachePolicy<T> other) => CachePolicy((entity) => canCache(entity) && other.canCache(entity));

  /// Composes a policy by concatenating multiple other policies from list
  static CachePolicy<S> any<S extends SnowflakeEntity>(List<CachePolicy<S>> policies) =>
      CachePolicy((entity) => policies.any((policy) => policy.canCache(entity)));
}

/// Cache policies for caching members
class MemberCachePolicy extends CachePolicy<IMember> {
  /// Do not cache members
  static final CachePolicy<IMember> none = MemberCachePolicy((member) => false);

  /// Cache all members
  static final CachePolicy<IMember> all = MemberCachePolicy((member) => true);

  /// Cache members which have online status
  static final CachePolicy<IMember> online = MemberCachePolicy((member) => member.user.getFromCache()?.status?.isOnline ?? false);

  /// Cache only members which have voice state not null
  static final CachePolicy<IMember> voice = MemberCachePolicy((member) => member.voiceState != null);

  /// Cache only member which are owner of guild
  static final CachePolicy<IMember> owner = MemberCachePolicy((member) => member.guild.getFromCache()?.owner.id == member.id);

  /// Default policy is [owner] or [voice]. So it caches guild owners and users in voice channels
  static final CachePolicy<IMember> def = owner.or(voice);

  /// Constructor
  MemberCachePolicy(CachePolicyPredicate<IMember> predicate) : super(predicate);
}

/// Cache policies for caching channels
class ChannelCachePolicy extends CachePolicy<IChannel> {
  /// Do not cache channels
  static final CachePolicy<IChannel> none = ChannelCachePolicy((channel) => false);

  /// Cache all channels
  static final CachePolicy<IChannel> all = ChannelCachePolicy((channel) => true);

  /// Cache only voice channels
  static final CachePolicy<IChannel> voice = ChannelCachePolicy((channel) => channel is IVoiceGuildChannel);

  /// Cache only text channels
  static final CachePolicy<IChannel> text = ChannelCachePolicy((channel) => channel is ITextChannel);

  /// Cache only thread channels
  static final CachePolicy<IChannel> thread = ChannelCachePolicy((channel) => channel is IThreadChannel);

  /// Default policy is [all]
  static final CachePolicy<IChannel> def = all;

  /// Constructor
  ChannelCachePolicy(CachePolicyPredicate<IChannel> predicate) : super(predicate);
}

class MessageCachePolicy extends CachePolicy<IMessage> {
  /// Do not any messages
  static final CachePolicy<IMessage> none = MessageCachePolicy((message) => false);

  /// Cache all messages
  static final CachePolicy<IMessage> all = MessageCachePolicy((message) => true);

  /// Cache only guild messages
  static final CachePolicy<IMessage> guildMessages = MessageCachePolicy((message) => message.guild != null || message.member != null);

  /// Cache only dm messages
  static final CachePolicy<IMessage> dmMessages = MessageCachePolicy((message) => message.guild == null && message.member == null);

  /// Default policy is [all]
  static final CachePolicy<IMessage> def = all;

  /// Constructor
  MessageCachePolicy(CachePolicyPredicate<IMessage> predicate) : super(predicate);
}
