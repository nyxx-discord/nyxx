part of nyxx;

/// Specifies objects which can be converted to [Builder]
// ignore: one_member_abstracts
abstract class Convertable<T extends Builder> {
  /// Returns instance of [Builder] with current data
  T toBuilder();
}
