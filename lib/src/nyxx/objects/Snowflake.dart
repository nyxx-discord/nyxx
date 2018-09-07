part of nyxx;

/// [Snowflake] represents id system used by Discord.
/// [id] property is actual id of entity which holds [Snowflake].
class Snowflake implements Comparable<Snowflake> {
  static final discordEpoch = 1420070400000;
  static final snowflakeDateOffset = 4194304;

  String _id;
  DateTime _timestamp;

  /// Full snowflake id
  String get id => id;

  /// Returns timestamp included in [Snowflake]
  /// [Snowflake reference](https://discordapp.com/developers/docs/reference#snowflakes)
  DateTime get timestamp {
    if(_timestamp == null) {
      _timestamp = DateTime.fromMillisecondsSinceEpoch(
          ((int.parse(_id) / snowflakeDateOffset) + discordEpoch).toInt());
      return _timestamp;
    }

    return _timestamp;
  }

  /// Creates new instance of [Snowflake] from String value.
  Snowflake(this._id);

  /// Creates synthetic snowflake based on current time
  Snowflake.fromNow() {
    this._timestamp = DateTime.now();
    this._id = _parseId(_timestamp);
  }

  /// Creates first snowflake which can be deleted by `bulk-delete messages`
  Snowflake.bulk() {
    this._timestamp = DateTime.now().subtract(Duration(days: 14));
    this._id = _parseId(_timestamp);
  }

  /// Creates synthetic snowflake based on given [date].
  Snowflake.fromDateTime(DateTime date) {
    this._timestamp = date;
    this._id = _parseId(_timestamp);
  }

  /// Returns true if [first] Snowflake was created is before [second].
  static bool compareDates(Snowflake first, Snowflake second)
    => first.timestamp.compareTo(second._timestamp) == -1;

  //  Parses id from dateTime
  static String _parseId(DateTime timestamp) =>
    ((timestamp.millisecondsSinceEpoch - discordEpoch) * snowflakeDateOffset).toString();

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
  int compareTo(Snowflake other) => other.id == this._id ? 0 : -1;
}
