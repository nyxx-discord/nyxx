part of nyxx;

/// [Snowflake] represents id system used by Discord.
/// [id] property is actual id of entity which holds [Snowflake].
class Snowflake implements Comparable<Snowflake> {
  /// START OF DISCORD EPOCH
  static const discordEpoch = 1420070400000;

  /// Offset of date in snowflake
  static const snowflakeDateOffset = 1 << 22;

  late final int _id;

  /// Full snowflake id
  int get id => _id;

  /// Returns timestamp included in [Snowflake]
  /// [Snowflake reference](https://discordapp.com/developers/docs/reference#snowflakes)
  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch((_id >> 22).toInt() + discordEpoch, isUtc: true);

  /// Creates new instance of [Snowflake].
  Snowflake(dynamic id) {
    if (id is int) {
      _id = id;
    } else {
      try {
        _id = int.parse(id.toString());
      } on FormatException {
        throw InvalidSnowflakeException._new(id);
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
  bool isBefore(Snowflake s) => this.timestamp.isBefore(s.timestamp);

  /// Checks if given [Snowflake] [s] is created after this instance
  bool isAfter(Snowflake s) => this.timestamp.isAfter(s.timestamp);

  /// Compares two Snowflakes based on creation date
  static int compareDates(Snowflake first, Snowflake second) => first.timestamp.compareTo(second.timestamp);

  //  Parses id from dateTime
  static int _parseId(DateTime timestamp) => (timestamp.millisecondsSinceEpoch - discordEpoch) * snowflakeDateOffset;

  @override
  String toString() => _id.toString();

  @override
  bool operator ==(dynamic other) {
    if (other is Snowflake) return other.id == this._id;
    if (other is int) return other == this._id;
    if (other is String) return other == this._id.toString();
    if (other is SnowflakeEntity) return other.id == this._id;

    return false;
  }

  @override
  int get hashCode => this._id.hashCode;

  @override
  int compareTo(Snowflake other) => compareDates(this, other);
}
