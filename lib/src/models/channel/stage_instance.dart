import 'dart:async';

import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

/// {@template stage_instance}
/// Information about a live stage.
/// {@endtemplate}
class StageInstance extends SnowflakeEntity<StageInstance> {
  /// The manager this [StageInstance] is associated with.
  final ChannelManager manager;

  /// The ID of the guild this instance is in.
  final Snowflake guildId;

  /// The ID of the channel this instance is for.
  final Snowflake channelId;

  /// The topic of this instance.
  final String topic;

  /// The privacy level of this instance.
  final PrivacyLevel privacyLevel;

  /// The ID of the scheduled event associated with this instance.
  final Snowflake? scheduledEventId;

  /// {@macro stage_instance}
  /// @nodoc
  StageInstance({
    required super.id,
    required this.manager,
    required this.guildId,
    required this.channelId,
    required this.topic,
    required this.privacyLevel,
    required this.scheduledEventId,
  });

  /// The guild this instance is in.
  PartialGuild get guild => manager.client.guilds[guildId];

  /// The channel this instance is in.
  PartialChannel get channel => manager.client.channels[channelId];

  /// The scheduled event associated with this instance.
  PartialScheduledEvent? get scheduledEvent => scheduledEventId == null ? null : guild.scheduledEvents[scheduledEventId!];

  @override
  Future<StageInstance> fetch() => manager.fetchStageInstance(channelId);

  @override
  Future<StageInstance> get() async => manager.stageInstanceCache[channelId] ?? await fetch();
}

/// The privacy level of a [StageInstance].
enum PrivacyLevel {
  public._(1),
  guildOnly._(2);

  final int value;

  const PrivacyLevel._(this.value);

  /// Parse a [PrivacyLevel] from an [int].
  ///
  /// The [value] must be a valid privacy level.
  factory PrivacyLevel.parse(int value) => PrivacyLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Unknown privacy level', value),
      );
}
