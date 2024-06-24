import 'package:nyxx/src/utils/enum_like.dart';
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
final class MessageActivityType extends EnumLike<int, MessageActivityType> {
  static const join = MessageActivityType(1);
  static const spectate = MessageActivityType(2);
  static const listen = MessageActivityType(3);
  static const joinRequest = MessageActivityType(5);

  /// @nodoc
  const MessageActivityType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  MessageActivityType.parse(int value) : this(value);
}
