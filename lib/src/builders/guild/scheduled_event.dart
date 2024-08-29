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

  RecurrenceRuleBuilder? recurrenceRule;

  ScheduledEventBuilder({
    this.channelId,
    this.metadata,
    required this.name,
    required this.privacyLevel,
    required this.scheduledStartTime,
    this.scheduledEndTime,
    this.description,
    required this.type,
    this.image,
    this.recurrenceRule,
  });

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId.toString(),
        if (metadata != null) 'entity_metadata': {'location': metadata!.location},
        'name': name,
        'privacy_level': privacyLevel.value,
        'scheduled_start_time': scheduledStartTime.toIso8601String(),
        if (scheduledEndTime != null) 'scheduled_end_time': scheduledEndTime!.toIso8601String(),
        if (description != null) 'description': description,
        'entity_type': type.value,
        if (image != null) 'image': image!.buildDataString(),
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule!.build(),
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

  RecurrenceRuleBuilder? recurrenceRule;

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
    this.recurrenceRule,
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
        if (recurrenceRule != null) 'recurrence_rule': recurrenceRule!.build(),
      };
}

class RecurrenceRuleBuilder extends CreateBuilder<RecurrenceRule> {
  DateTime start;
  RecurrenceRuleFrequency frequency;
  int interval;
  List<RecurrenceRuleWeekday>? byWeekday;
  List<RecurrenceRuleNWeekday>? byNWeekday;
  List<RecurrenceRuleMonth>? byMonth;
  List<int>? byMonthDay;

  RecurrenceRuleBuilder({
    required this.start,
    required this.frequency,
    required this.interval,
    this.byWeekday,
    this.byNWeekday,
    this.byMonth,
    this.byMonthDay,
  });

  RecurrenceRuleBuilder.daily({required this.start, this.byWeekday})
      : frequency = RecurrenceRuleFrequency.daily,
        interval = 1;

  RecurrenceRuleBuilder.weekly({
    required this.start,
    required this.interval,
    RecurrenceRuleWeekday? day,
  })  : frequency = RecurrenceRuleFrequency.weekly,
        byWeekday = day == null ? null : [day];

  RecurrenceRuleBuilder.monthly({
    required this.start,
    RecurrenceRuleNWeekday? day,
  })  : frequency = RecurrenceRuleFrequency.monthly,
        interval = 1,
        byNWeekday = day == null ? null : [day];

  RecurrenceRuleBuilder.yearly({required this.start, (RecurrenceRuleMonth, int)? day})
      : frequency = RecurrenceRuleFrequency.yearly,
        interval = 1,
        byMonth = day == null ? null : [day.$1],
        byMonthDay = day == null ? null : [day.$2];

  @override
  Map<String, Object?> build() => {
        'start': start.toIso8601String(),
        'frequency': frequency.value,
        'interval': interval,
        'by_weekday': byWeekday?.map((weekday) => weekday.value).toList(),
        'by_n_weekday': byNWeekday?.map((nWeekday) => {'n': nWeekday.n, 'day': nWeekday.day.value}).toList(),
        'by_month': byMonth?.map((month) => month.value).toList(),
        'by_month_day': byMonthDay,
      };
}
