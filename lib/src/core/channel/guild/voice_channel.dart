import 'dart:async';

import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/guild/activity_types.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/exceptions/invalid_shard_exception.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/enum.dart';

abstract class IVoiceGuildChannel implements IGuildChannel {
  /// The channel's bitrate.
  int? get bitrate;

  /// The channel's user limit.
  int? get userLimit;

  /// Channel voice region id, automatic when set to null
  String? get rtcRegion;

  /// Connects client to channel
  void connect({bool selfMute = false, bool selfDeafen = false});

  /// Disconnects use from channel.
  void disconnect();

  /// Creates activity invite. Currently in beta
  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses});
}

class VoiceGuildChannel extends GuildChannel implements IVoiceGuildChannel {
  /// The channel's bitrate.
  @override
  late final int? bitrate;

  /// The channel's user limit.
  @override
  late final int? userLimit;

  @override
  late final String? rtcRegion;

  /// Creates an instance of [VoiceGuildChannel]
  VoiceGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    bitrate = raw["bitrate"] as int?;
    userLimit = raw["user_limit"] as int?;
    rtcRegion = raw['rtc_region'] as String?;
  }

  /// Connects client to channel
  @override
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  @override
  void disconnect() {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, null);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  @override
  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses}) =>
      client.httpEndpoints.createVoiceActivityInvite(Snowflake(type.value), id, maxAge: maxAge, maxUses: maxUses);
}

abstract class ITextVoiceTextChannel implements IVoiceGuildChannel, ITextChannel, Mentionable {}

class TextVoiceTextChannel extends VoiceGuildChannel implements ITextVoiceTextChannel {
  @override
  late final SnowflakeCache<IMessage> messageCache = SnowflakeCache(client.options.messageCacheSize);

  // Used to create infinite typing loop
  Timer? _typing;

  TextVoiceTextChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId);

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(id, messages);

  /// Connects client to channel
  @override
  void connect({bool selfMute = false, bool selfDeafen = false}) {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, id, selfMute: selfMute, selfDeafen: selfDeafen);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  /// Disconnects use from channel.
  @override
  void disconnect() {
    if (client is! NyxxWebsocket) {
      throw UnsupportedError("Cannot connect with NyxxRest");
    }

    try {
      final shard = (client as NyxxWebsocket).shardManager.shards.firstWhere((element) => element.guilds.contains(guild.id));

      shard.changeVoiceState(guild.id, null);
    } on Error {
      throw InvalidShardException("Cannot find shard for this channel!");
    }
  }

  @override
  Future<IInvite> createActivityInvite(VoiceActivityType type, {int? maxAge, int? maxUses}) =>
      client.httpEndpoints.createVoiceActivityInvite(Snowflake(type.value), id, maxAge: maxAge, maxUses: maxUses);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(id, messageId);

    if (client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      messageCache[messageId] = message;
    }

    return message;
  }

  /// Returns pinned [Message]s for channel.
  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(id);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  @override
  IMessage? getMessage(Snowflake id) => messageCache[id];

  /// The channel's mention string.
  @override
  String get mention => "<#$id>";

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(id, builder);

  @override
  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(id);

  @override
  void startTypingLoop() {
    startTyping();
    _typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => _typing?.cancel();
}

abstract class IStageVoiceGuildChannel implements IVoiceGuildChannel {
  /// Gets the stage instance associated with the Stage channel, if it exists.
  Future<IStageChannelInstance> getStageChannelInstance();

  /// Deletes the Stage instance.
  Future<void> deleteStageChannelInstance();

  /// Creates a new Stage instance associated to a Stage channel.
  Future<IStageChannelInstance> createStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel});

  /// Updates fields of an existing Stage instance.
  Future<IStageChannelInstance> updateStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel});
}

class StageVoiceGuildChannel extends VoiceGuildChannel implements IStageVoiceGuildChannel {
  StageVoiceGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId);

  /// Gets the stage instance associated with the Stage channel, if it exists.
  @override
  Future<IStageChannelInstance> getStageChannelInstance() => client.httpEndpoints.getStageChannelInstance(id);

  /// Deletes the Stage instance.
  @override
  Future<void> deleteStageChannelInstance() => client.httpEndpoints.deleteStageChannelInstance(id);

  /// Creates a new Stage instance associated to a Stage channel.
  @override
  Future<IStageChannelInstance> createStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      client.httpEndpoints.createStageChannelInstance(id, topic, privacyLevel: privacyLevel);

  /// Updates fields of an existing Stage instance.
  @override
  Future<IStageChannelInstance> updateStageChannelInstance(String topic, {StageChannelInstancePrivacyLevel? privacyLevel}) =>
      client.httpEndpoints.updateStageChannelInstance(id, topic, privacyLevel: privacyLevel);
}

abstract class IStageChannelInstance implements SnowflakeEntity {
  /// The guild id of the associated Stage channel
  Cacheable<Snowflake, IGuild> get guild;

  /// The id of the associated Stage channel
  Cacheable<Snowflake, IStageVoiceGuildChannel> get channel;

  /// The topic of the Stage instance
  String get topic;

  /// The privacy level of the Stage instance
  StageChannelInstancePrivacyLevel get privacyLevel;

  /// Whether or not Stage discovery is disabled
  bool get disoverableDisabled;
}

/// A [StageChannelInstance] holds information about a live stage.
class StageChannelInstance extends SnowflakeEntity implements IStageChannelInstance {
  /// The guild id of the associated Stage channel
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The id of the associated Stage channel
  @override
  late final Cacheable<Snowflake, IStageVoiceGuildChannel> channel;

  /// The topic of the Stage instance
  @override
  late final String topic;

  /// The privacy level of the Stage instance
  @override
  late final StageChannelInstancePrivacyLevel privacyLevel;

  /// Whether or not Stage discovery is disabled
  @override
  late final bool disoverableDisabled;

  /// Creates an instance of [StageChannelInstance]
  StageChannelInstance(INyxx client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    channel = ChannelCacheable(client, Snowflake(raw["channel_id"]));
    topic = raw["topic"] as String;
    privacyLevel = StageChannelInstancePrivacyLevel.from(raw["privacy_level"] as int);
    disoverableDisabled = raw["discoverable_disabled"] as bool;
  }
}

/// The privacy level of the Stage instance
class StageChannelInstancePrivacyLevel extends IEnum<int> {
  /// The Stage instance is visible publicly, such as on Stage discovery.
  static const StageChannelInstancePrivacyLevel public = StageChannelInstancePrivacyLevel(1);

  /// The Stage instance is visible to only guild members.
  static const StageChannelInstancePrivacyLevel guildOnly = StageChannelInstancePrivacyLevel(2);

  /// Creates an instance of [StageChannelInstancePrivacyLevel]
  const StageChannelInstancePrivacyLevel(int value) : super(value);

  /// Create [StageChannelInstancePrivacyLevel] from [value]
  StageChannelInstancePrivacyLevel.from(int value) : super(value);
}
