part of nyxx;

/// [Snowflake] represents id system used by Discord.
/// [id] property is actual id of entity which holds [Snowflake].
class Snowflake implements Comparable<Snowflake> {
  static final discordEpoch = 1420070400000;
  static final snowflakeDateOffset = 1 << 22;

  final String _id;

  /// Creates new instance of [Snowflake].
  Snowflake(dynamic id) : _id = id.toString();

  /// Creates synthetic snowflake based on current time
  Snowflake.fromNow() : _id = _parseId(DateTime.now());

  /// Creates first snowflake which can be deleted by `bulk-delete messages`
  Snowflake.bulk() : _id = _parseId(DateTime.now().subtract(Duration(days: 14)));

  /// Creates synthetic snowflake based on given [date].
  Snowflake.fromDateTime(DateTime date) : _id = _parseId(date);

  /// Full snowflake id
  String get id => _id;

  /// Compares two Snowflakes based on creation date
  static int compareDates(Snowflake first, Snowflake second) =>
      first.timestamp.compareTo(second.timestamp);

  //  Parses id from dateTime
  static String _parseId(DateTime timestamp) =>
      ((timestamp.millisecondsSinceEpoch - discordEpoch) * snowflakeDateOffset)
          .toString();

  /// Returns timestamp included in [Snowflake]
  /// [Snowflake reference](https://discordapp.com/developers/docs/reference#snowflakes)
  DateTime get timestamp =>
      DateTime.fromMillisecondsSinceEpoch((BigInt.parse(_id) >> 22).toInt() + discordEpoch, isUtc: true);

  @override
  String toString() => _id;

  num toNum() => int.parse(this._id);

  @override
  bool operator ==(other) {
    if (other is Snowflake) return other.id == this._id;
    if (other is int) return other.toString() == this._id;
    if (other is String) return other == this._id;

    return false;
  }

  @override
  int get hashCode => this._id.hashCode;

  @override
  int compareTo(Snowflake other) => compareDates(this, other);
}
