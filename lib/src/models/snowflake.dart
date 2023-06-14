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
  static final zero = Snowflake(0);

  /// The value of this snowflake.
  ///
  /// This will always be positive.
  final BigInt value;

  /// The time at which this snowflake was created.
  DateTime get timestamp => epoch.add(Duration(milliseconds: millisecondsSinceEpoch));

  /// The number of milliseconds since the [epoch].
  ///
  /// Discord uses a non-standard epoch for their snowflakes. As such,
  /// [DateTime.fromMillisecondsSinceEpoch] will not work with this value. Users should instead use
  /// the [timestamp] getter.
  int get millisecondsSinceEpoch => (value >> 22).toInt();

  static final _workerIdMask = BigInt.from(0x3E0000);
  static final _processIdMask = BigInt.from(0x1F000);
  static final _incrementMask = BigInt.from(0xFFF);

  /// The internal worker ID for this snowflake.
  ///
  /// {@template internal_field}
  /// This is an internal field and has no practical application.
  /// {@endtemplate}
  int get workerId => ((value & _workerIdMask) >> 17).toInt();

  /// The internal process ID for this snowflake.
  ///
  /// {@macro internal_field}
  int get processId => ((value & _processIdMask) >> 12).toInt();

  /// The internal increment value for this snowflake.
  ///
  /// {@macro internal_field}
  int get increment => (value & _incrementMask).toInt();

  /// Whether this snowflake has a value of `0`.
  bool get isZero => value == BigInt.zero;

  /// Create a new snowflake from an integer value.
  ///
  /// {@macro snowflake}
  factory Snowflake(int value) => Snowflake.fromBigInt(BigInt.from(value));

  /// Parse a string value to a snowflake.
  ///
  /// The [value] must be a valid integer as per [int.parse].
  ///
  /// {@macro snowflake}
  factory Snowflake.parse(String value) => Snowflake.fromBigInt(BigInt.parse(value));

  /// Create a snowflake with a timestamp equal to the current time.
  ///
  /// {@macro snowflake}
  factory Snowflake.now() => Snowflake.fromDateTime(DateTime.now());

  /// Create a snowflake from a [BigInt].
  ///
  /// {@macro snowflake}
  const Snowflake.fromBigInt(this.value);

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
