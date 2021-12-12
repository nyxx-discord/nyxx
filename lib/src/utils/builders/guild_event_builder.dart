import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';

class GuildEventBuilder implements Builder {
  /// The channel id of the scheduled event, set to null if changing entity type to EXTERNAL
  Snowflake? channelId = Snowflake.zero();

  /// The entity metadata of the scheduled event
  EntityMetadataBuilder? metadata;

  /// The name of the scheduled event
  String? name;

  /// The privacy level of the scheduled event
  GuildEventPrivacyLevel? privacyLevel;

  /// The time to schedule the scheduled event
  DateTime? startDate;

  /// The time when the scheduled event is scheduled to end
  DateTime? endDate;

  /// The description of the scheduled event
  String? description;

  /// The entity type of the scheduled event
  GuildEventType? type;

  /// The status of the scheduled event
  GuildEventStatus? status;

  @override
  RawApiMap build() => {
        if (channelId?.id == 0) "channel_id": channelId.toString(),
        if (metadata != null) 'entity_metadata': metadata!.build(),
        if (name != null) 'name': name,
        if (privacyLevel != null) 'privacy_level': privacyLevel!.value,
        if (startDate != null) 'scheduled_start_time': startDate!.toIso8601String(),
        if (endDate != null) 'scheduled_end_time': endDate!.toIso8601String(),
        if (description != null) 'description': description,
        if (type != null) 'entity_type': type,
        if (status != null) 'status': status!.value
      };
}

class EntityMetadataBuilder implements Builder {
  String? location;

  EntityMetadataBuilder(this.location);

  @override
  RawApiMap build() => {if (location != null) 'location': location};
}
