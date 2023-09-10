/// A unique ID used to identify objects in the API.
///
/// {@template snowflake}
/// Snowflakes are generally unique across the API except in some cases where children share their
/// parent's IDs.
///
/// {@template snowflake_ordering}
/// Snowflakes are ordered first by their [timestamp], then by [workerId], [processId] and
/// [increment]. The last three fields are only used internally by Discord so the only ordering
/// visible through the API is by [timestamp].
/// {@endtemplate}
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/reference#snowflakes
/// {@endtemplate}
class Snowflake implements Comparable<Snowflake> {
  /// A [DateTime] representing the start of the Discord epoch.
  ///
  /// This is used as the epoch for [millisecondsSinceEpoch].
  static final epoch = DateTime.utc(2015, 1, 1, 0, 0, 0);

  /// The duration after which bulk delete operations are no longer valid.
  static const bulkDeleteLimit = Duration(days: 14);

  /// A snowflake with a value of 0.
  static const zero = Snowflake(0);

  /// The value of this snowflake.
  ///
  /// While this is stored in a signed [int], Discord treats this as an unsigned value.
  final int value;

  /// The time at which this snowflake was created.
  DateTime get timestamp => epoch.add(Duration(milliseconds: millisecondsSinceEpoch));

  /// The number of milliseconds since the [epoch].
  ///
  /// Discord uses a non-standard epoch for their snowflakes. As such,
  /// [DateTime.fromMillisecondsSinceEpoch] will not work with this value. Users should instead use
  /// the [timestamp] getter.
  int get millisecondsSinceEpoch => value >> 22;

  /// The internal worker ID for this snowflake.
  ///
  /// {@template internal_field}
  /// This is an internal field and has no practical application.
  /// {@endtemplate}
  int get workerId => (value & 0x3E0000) >> 17;

  /// The internal process ID for this snowflake.
  ///
  /// {@macro internal_field}
  int get processId => (value & 0x1F000) >> 12;

  /// The internal increment value for this snowflake.
  ///
  /// {@macro internal_field}
  int get increment => value & 0xFFF;

  /// Whether this snowflake has a value of `0`.
  bool get isZero => value == 0;

  /// Create a new snowflake from an integer value.
  ///
  /// {@macro snowflake}
  const Snowflake(this.value);

  /// Parse a string or integer value to a snowflake.
  ///
  /// Both data types are accepted as Discord's Gateway can transmit Snowflakes as strings or integers when using the [GatewayPayloadFormat.etf] payload format.
  ///
  /// The [value] must be an [int] or a [String] parsable by [int.parse].
  ///
  /// {@macro snowflake}
  // TODO: This method will fail once snowflakes become larger than 2^63.
  // We need to parse the unsigned [value] into a signed [int].
  factory Snowflake.parse(Object /* String | int */ value) {
    assert(value is String || value is int);

    if (value is! int) {
      value = int.parse(value.toString());
    }

    return Snowflake(value);
  }

  /// Create a snowflake with a timestamp equal to the current time.
  ///
  /// {@macro snowflake}
  factory Snowflake.now() => Snowflake.fromDateTime(DateTime.now());

  /// Create a snowflake with a timestamp equal to [dateTime].
  ///
  /// [dateTime] must be a [DateTime] which is at the same moment as or after [epoch].
  ///
  /// {@macro snowflake}
  factory Snowflake.fromDateTime(DateTime dateTime) {
    assert(
      dateTime.isAfter(epoch) || dateTime.isAtSameMomentAs(epoch),
      'Cannot create a Snowflake before the epoch.',
    );

    return Snowflake(dateTime.difference(epoch).inMilliseconds << 22);
  }

  /// Create a snowflake representing the oldest time at which bulk delete operations will work.
  ///
  /// {@macro snowflake}
  factory Snowflake.firstBulk() => Snowflake.fromDateTime(DateTime.now().subtract(bulkDeleteLimit));

  /// Return `true` if this snowflake has a [timestamp] before [other]'s timestamp.
  bool isBefore(Snowflake other) => timestamp.isBefore(other.timestamp);

  /// Return `true` if this snowflake has a [timestamp] after [other]'s timestamp.
  bool isAfter(Snowflake other) => timestamp.isAfter(other.timestamp);

  /// Return `true` if this snowflake has a [timestamp] at the same time as [other]'s timestamp.
  bool isAtSameMomentAs(Snowflake other) => timestamp.isAtSameMomentAs(other.timestamp);

  /// Return a snowflake [duration] after this snowflake.
  ///
  /// The returned snowflake has no [workerId], [processId] or [increment].
  Snowflake operator +(Duration duration) => Snowflake.fromDateTime(timestamp.add(duration));

  /// Return a snowflake [duration] before this snowflake.
  ///
  /// The returned snowflake has no [workerId], [processId] or [increment].
  Snowflake operator -(Duration duration) => Snowflake.fromDateTime(timestamp.subtract(duration));

  @override
  int compareTo(Snowflake other) => value.compareTo(other.value);

  /// Whether this snowflake is before [other].
  ///
  /// See [isBefore] for details.
  bool operator <(Snowflake other) => isBefore(other);

  /// Whether this snowflake is after [other].
  ///
  /// See [isAfter] for details.
  bool operator >(Snowflake other) => isAfter(other);

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Snowflake && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
