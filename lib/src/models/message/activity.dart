import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class MessageActivity with ToStringHelper {
  final MessageActivityType type;

  final String? partyId;

  MessageActivity({
    required this.type,
    required this.partyId,
  });
}

enum MessageActivityType {
  join._(1),
  spectate._(2),
  listen._(3),
  joinRequest._(5);

  final int value;

  const MessageActivityType._(this.value);

  factory MessageActivityType.parse(int value) => MessageActivityType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown MessageActivityType', value),
      );

  @override
  String toString() => 'MessageActivityType($value)';
}
