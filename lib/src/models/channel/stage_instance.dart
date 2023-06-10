import 'dart:async';

import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';

class StageInstance extends SnowflakeEntity<StageInstance> with SnowflakeEntityMixin<StageInstance> {
  final ChannelManager manager;

  final Snowflake guildId;

  final Snowflake channelId;

  final String topic;

  final PrivacyLevel privacyLevel;

  final Snowflake? scheduledEventId;

  StageInstance({
    required super.id,
    required this.manager,
    required this.guildId,
    required this.channelId,
    required this.topic,
    required this.privacyLevel,
    required this.scheduledEventId,
  });

  @override
  Future<StageInstance> fetch() => manager.fetchStageInstance(channelId);

  @override
  FutureOr<StageInstance> get() async => manager.stageInstanceCache[channelId] ?? await fetch();
}

enum PrivacyLevel {
  public._(1),
  guildOnly._(2);

  final int value;

  const PrivacyLevel._(this.value);

  factory PrivacyLevel.parse(int value) => PrivacyLevel.values.firstWhere(
        (level) => level.value == value,
        orElse: () => throw FormatException('Unknown privacy level', value),
      );
}
