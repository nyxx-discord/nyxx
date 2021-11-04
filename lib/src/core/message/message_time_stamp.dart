import 'package:nyxx/src/utils/enum.dart';

/// Style of inline timestamp that can be embedded into message
class TimeStampStyle extends IEnum<String> {
  /// Short Time
  static const TimeStampStyle shortTime = TimeStampStyle._create("t");

  /// Long Time
  static const TimeStampStyle longTime = TimeStampStyle._create("T");

  /// Short Date
  static const TimeStampStyle shortDate = TimeStampStyle._create("d");

  /// Long Date
  static const TimeStampStyle longDate = TimeStampStyle._create("D");

  /// Short Date/Time
  static const TimeStampStyle shortDateTime = TimeStampStyle._create("f");

  /// Long Date/Time
  static const TimeStampStyle longDateTime = TimeStampStyle._create("F");

  /// Relative Time
  static const TimeStampStyle relativeTime = TimeStampStyle._create("R");

  /// Default style
  static const TimeStampStyle def = TimeStampStyle.shortDateTime;

  /// Create instance of [TimeStampStyle] from [value]
  TimeStampStyle.from(String value) : super(value);
  const TimeStampStyle._create(String value) : super(value);

  /// Return
  String format(DateTime dateTime) => "<t:${dateTime.millisecondsSinceEpoch ~/ 1000}:${value}>";
}

abstract class IMessageTimestamp {
  /// Regex to parse message timestamp
  static final regex = RegExp(r"<t:(\d+)(:([tTDdFfR]+))?>");

  /// Style of timestamp
  TimeStampStyle get style;

  /// [DateTime] of timestamp
  DateTime get timeStamp;
}

class MessageTimestamp implements IMessageTimestamp {
  /// Style of timestamp
  @override
  late final TimeStampStyle style;

  /// [DateTime] of timestamp
  @override
  late final DateTime timeStamp;

  /// Creates an instance of [MessageTimestamp]
  MessageTimestamp(Match match) {
    timeStamp = DateTime.fromMillisecondsSinceEpoch(int.parse(match.group(1)!) * 1000);

    final styleMatch = match.group(3);
    style = styleMatch != null ? TimeStampStyle.from(styleMatch) : TimeStampStyle.def;
  }
}
