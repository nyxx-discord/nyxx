import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template message_activity}
/// Activity data for rich presence related messages.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-activity-structure
/// {@endtemplate}
class MessageActivity with ToStringHelper {
  /// The type of this activity.
  final MessageActivityType type;

  /// The party ID of the Rich Presence event.
  final String? partyId;

  /// {@macro message_activity}
  /// @nodoc
  MessageActivity({
    required this.type,
    required this.partyId,
  });
}

/// The type of a message activity.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-activity-types
enum MessageActivityType {
  join._(1),
  spectate._(2),
  listen._(3),
  joinRequest._(5);

  /// The value of this [MessageActivityType].
  final int value;

  const MessageActivityType._(this.value);

  /// Parse a [MessageActivityType] from an [int].
  ///
  /// [value] must be a valid message activity type.
  factory MessageActivityType.parse(int value) => MessageActivityType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown MessageActivityType', value),
      );

  @override
  String toString() => 'MessageActivityType($value)';
}
