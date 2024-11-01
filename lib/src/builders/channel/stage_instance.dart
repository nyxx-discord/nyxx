import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/snowflake.dart';

/// A Stage Instance holds information about a live stage.
class StageInstanceBuilder extends CreateBuilder<StageInstance> {
  /// {@template stage_instance_topic}
  /// The topic of the Stage instance (1-120 characters).
  /// {@endtemplate}
  String topic;

  /// {@template stage_instance_privacy_level}
  /// The privacy level of the Stage instance.
  /// {@endtemplate}
  PrivacyLevel? privacyLevel;

  /// Notify @everyone that a Stage instance has started.
  bool? sendStartNotification;

  /// The guild scheduled event associated with this Stage instance.
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
  /// {@macro stage_instance_topic}
  String? topic;

  /// {@macro stage_instance_privacy_level}
  PrivacyLevel? privacyLevel;

  StageInstanceUpdateBuilder({this.topic, this.privacyLevel});

  @override
  Map<String, Object?> build() => {
        if (topic != null) 'topic': topic,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
      };
}
