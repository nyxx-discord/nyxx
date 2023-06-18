import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';

class StageInstanceBuilder extends CreateBuilder<StageInstance> {
  final String topic;

  final PrivacyLevel? privacyLevel;

  final bool? sendStartNotification;

  StageInstanceBuilder({
    required this.topic,
    this.privacyLevel,
    this.sendStartNotification,
  });

  @override
  Map<String, Object?> build() => {
        'topic': topic,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
        if (sendStartNotification != null) 'send_start_notification': sendStartNotification,
      };
}

class StageInstanceUpdateBuilder extends UpdateBuilder<StageInstance> {
  final String? topic;

  final PrivacyLevel? privacyLevel;

  StageInstanceUpdateBuilder({this.topic, this.privacyLevel});

  @override
  Map<String, Object?> build() => {
        if (topic != null) 'topic': topic,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
      };
}
