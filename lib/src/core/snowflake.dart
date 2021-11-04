import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/internal/exceptions/invalid_snowflake_exception.dart';

/// [Snowflake] represents id system used by Discord.
/// [id] property is actual id of entity which holds [Snowflake].
class Snowflake implements Comparable<Snowflake> {
  /// START OF DISCORD EPOCH
  static const discordEpoch = 1420070400000;

  /// Offset of date in snowflake
  static const snowflakeDateOffset = 1 << 22;

  final int _id;

  /// Full snowflake id
  int get id => _id;

  /// Returns timestamp included in [Snowflake]
  /// [Snowflake reference](https://discordapp.com/developers/docs/reference#snowflakes)
  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch((_id >> 22).toInt() + discordEpoch, isUtc: true);

  /// Returns true if snowflake is zero
  bool get isZero => id == 0;

  /// Creates new instance of [Snowflake].
  const Snowflake.value(this._id);

  /// Creates new instance with value of 0
  const Snowflake.zero() : _id = 0;

  /// Creates instance of an Snowflake
  factory Snowflake(dynamic id) {
    if (id is int) {
      return Snowflake.value(id);
    } else {
      try {
        return Snowflake.value(int.parse(id.toString()));
      } on FormatException {
        throw InvalidSnowflakeException(id);
      }
    }
  }

  /// Creates synthetic snowflake based on current time
  Snowflake.fromNow() : _id = _parseId(DateTime.now());

  /// Creates first snowflake which can be deleted by `bulk-delete messages`
  Snowflake.bulk() : _id = _parseId(DateTime.now().subtract(const Duration(days: 14)));

  /// Creates synthetic snowflake based on given [date].
  Snowflake.fromDateTime(DateTime date) : _id = _parseId(date);

  /// Returns [SnowflakeEntity] from current [Snowflake]
  SnowflakeEntity toSnowflakeEntity() => SnowflakeEntity(this);

  /// Checks if given [Snowflake] [s] is created before this instance
  bool isBefore(Snowflake s) => timestamp.isBefore(s.timestamp);

  /// Checks if given [Snowflake] [s] is created after this instance
  bool isAfter(Snowflake s) => timestamp.isAfter(s.timestamp);

  /// Compares two Snowflakes based on creation date
  static int compareDates(Snowflake first, Snowflake second) => first.timestamp.compareTo(second.timestamp);

  //  Parses id from dateTime
  static int _parseId(DateTime timestamp) => (timestamp.millisecondsSinceEpoch - discordEpoch) * snowflakeDateOffset;

  @override
  String toString() => _id.toString();

  @override
  bool operator ==(dynamic other) {
    if (other is Snowflake) return other.id == _id;
    if (other is int) return other == _id;
    if (other is String) return other == _id.toString();
    if (other is SnowflakeEntity) return other.id == _id;

    return false;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  int compareTo(Snowflake other) => compareDates(this, other);
}
