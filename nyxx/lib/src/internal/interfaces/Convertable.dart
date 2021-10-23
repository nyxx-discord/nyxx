

/// Specifies objects which can be converted to [Builder]
// ignore: one_member_abstracts
abstract class Convertable<T> {
  /// Returns instance of [Builder] with current data
  T toBuilder();
}
