/// Provides abstraction for disposing object's resources when isn't needed anymore
// ignore: one_member_abstracts
abstract class Disposable {
  /// Perform cleanup
  Future<void> dispose();
}
