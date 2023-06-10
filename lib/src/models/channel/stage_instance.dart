import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class StageInstance with ToStringHelper {
  final Snowflake id;

  final Snowflake guildId;

  final Snowflake channelId;

  final String topic;

  final PrivacyLevel privacyLevel;

  final Snowflake? scheduledEventId;

  StageInstance({
    required this.id,
    required this.guildId,
    required this.channelId,
    required this.topic,
    required this.privacyLevel,
    required this.scheduledEventId,
  });
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
