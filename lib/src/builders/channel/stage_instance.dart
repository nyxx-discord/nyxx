import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/snowflake.dart';

class StageInstanceBuilder extends CreateBuilder<StageInstance> {
  String topic;

  PrivacyLevel? privacyLevel;

  bool? sendStartNotification;

  Snowflake? guildScheduledEventId;

  StageInstanceBuilder({
    required this.topic,
    this.privacyLevel,
    this.sendStartNotification,
    this.guildScheduledEventId,
  });

  @override
  Map<String, Object?> build() => {
        'topic': topic,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
        if (sendStartNotification != null) 'send_start_notification': sendStartNotification,
        if (guildScheduledEventId != null) 'guild_scheduled_event_id': guildScheduledEventId!.toString(),
      };
}

class StageInstanceUpdateBuilder extends UpdateBuilder<StageInstance> {
  String? topic;

  PrivacyLevel? privacyLevel;

  StageInstanceUpdateBuilder({this.topic, this.privacyLevel});

  @override
  Map<String, Object?> build() => {
        if (topic != null) 'topic': topic,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
      };
}
