part of nyxx;

/// [Snowflake] represents id system used by Discord.
/// [id] property is actual id of entity which holds [Snowflake].
class Snowflake implements Comparable<Snowflake> {
  /// Full snowflake id
  final String id;

  /// Creates new instance of [Snowflake].
  Snowflake(this.id);

  /// Creates const instance of Snowflake
  const Snowflake.static(this.id);

  /// Returns timestamp included in [Snowflake]
  /// [Snowflake reference](https://discordapp.com/developers/docs/reference#snowflakes)
  DateTime get timestamp => new DateTime.fromMillisecondsSinceEpoch(
      ((int.parse(id) / 4194304) + 1420070400000).toInt());

  @override
  String toString() => id;

  @override
  bool operator ==(other) {
    if (other is Snowflake) return other.id == this.id;
    if (other is int) return other.toString() == this.id;
    if (other is String) return other == this.id;

    return false;
  }

  @override
  int get hashCode => this.id.hashCode;

  @override
  int compareTo(Snowflake other) {
    if (other.id == this.id) return 1;

    return 0;
  }
}
