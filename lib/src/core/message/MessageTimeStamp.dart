part of nyxx;

/// Style of inline timestamp that can be embedded into message
class TimeStampStyle extends IEnum<String> {
  /// Short Time
  static const TimeStampStyle shortTime = const TimeStampStyle._create("t");
  /// Long Time
  static const TimeStampStyle longTime = const TimeStampStyle._create("T");
  /// Short Date
  static const TimeStampStyle shortDate = const TimeStampStyle._create("d");
  /// Long Date
  static const TimeStampStyle longDate = const TimeStampStyle._create("D");
  /// Short Date/Time
  static const TimeStampStyle shortDateTime = const TimeStampStyle._create("f");
  /// Long Date/Time
  static const TimeStampStyle longDateTime = const TimeStampStyle._create("F");
  /// Relative Time
  static const TimeStampStyle relativeTime = const TimeStampStyle._create("R");

  /// Default style
  static const TimeStampStyle def = TimeStampStyle.shortDateTime;

  /// Create instance of [TimeStampStyle] from [value]
  TimeStampStyle.from(String value): super(value);
  const TimeStampStyle._create(String value) : super(value);

  /// Return
  String format(DateTime dateTime) => "<t:${dateTime.millisecondsSinceEpoch ~/ 1000}:${this.value}>";
}

class MessageTimeStamp {
  static final regex = RegExp(r"<t:(\d+)(:([tTDdFfR]+))?>");

  /// Style of timestamp
  late final TimeStampStyle style;

  /// [DateTime] of timestamp
  late final DateTime timeStamp;

  MessageTimeStamp._new(Match match) {
    this.timeStamp = DateTime.fromMillisecondsSinceEpoch(int.parse(match.group(1)!) * 1000);

    final styleMatch = match.group(3);
    this.style = styleMatch != null
        ? TimeStampStyle.from(styleMatch)
        : TimeStampStyle.def;
  }
}
