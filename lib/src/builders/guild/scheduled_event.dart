import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/channel/stage_instance.dart';
import 'package:nyxx/src/models/guild/scheduled_event.dart';
import 'package:nyxx/src/models/snowflake.dart';

class ScheduledEventBuilder extends CreateBuilder<ScheduledEvent> {
  Snowflake? channelId;

  EntityMetadata? metadata;

  String name;

  PrivacyLevel privacyLevel;

  DateTime scheduledStartTime;

  DateTime? scheduledEndTime;

  String? description;

  ScheduledEntityType type;

  ImageBuilder? image;

  ScheduledEventBuilder({
    required this.channelId,
    this.metadata,
    required this.name,
    required this.privacyLevel,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.description,
    required this.type,
    this.image,
  });

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId.toString(),
        if (metadata != null) 'metadata': {'location': metadata!.location},
        'name': name,
        'privacy_level': privacyLevel.value,
        'scheduled_start_time': scheduledStartTime.toIso8601String(),
        if (scheduledEndTime != null) 'scheduled_end_time': scheduledEndTime!.toIso8601String(),
        if (description != null) 'description': description,
        'entity_type': type.value,
        if (image != null) 'image': image!.buildDataString(),
      };
}

class ScheduledEventUpdateBuilder extends UpdateBuilder<ScheduledEvent> {
  Snowflake? channelId;

  EntityMetadata? metadata;

  String? name;

  PrivacyLevel? privacyLevel;

  DateTime? scheduledStartTime;

  DateTime? scheduledEndTime;

  String? description;

  ScheduledEntityType? type;

  EventStatus? status;

  ImageBuilder? image;

  ScheduledEventUpdateBuilder({
    this.channelId = sentinelSnowflake,
    this.metadata = sentinelEntityMetadata,
    this.name,
    this.privacyLevel,
    this.scheduledStartTime,
    this.scheduledEndTime = sentinelDateTime,
    this.description = sentinelString,
    this.type,
    this.status,
    this.image,
  });

  @override
  Map<String, Object?> build() => {
        if (!identical(channelId, sentinelSnowflake)) 'channel_id': channelId?.toString(),
        if (!identical(metadata, sentinelEntityMetadata)) 'metadata': metadata == null ? null : {'location': metadata!.location},
        if (name != null) 'name': name,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
        if (scheduledStartTime != null) 'scheduled_start_time': scheduledStartTime!.toIso8601String(),
        if (!identical(scheduledEndTime, sentinelDateTime)) 'scheduled_end_time': scheduledEndTime?.toIso8601String(),
        if (!identical(description, sentinelString)) 'description': description,
        if (type != null) 'entity_type': type!.value,
        if (status != null) 'status': status!.value,
        if (image != null) 'image': image!.buildDataString(),
      };
}
