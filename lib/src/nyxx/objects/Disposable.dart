part of nyxx;

/// Provides abstraction for disposing object's resources when isn't needed anymore
abstract class Disposable {
  /// Perform cleanup
  Future<void> dispose();
}
