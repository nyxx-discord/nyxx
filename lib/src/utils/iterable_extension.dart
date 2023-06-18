/// An internal extension adding utility methods to [Iterable].
extension IterableExtension<T> on Iterable<T> {
  /// Same as [firstWhere], but returns `null` is no element is found.
  ///
  /// Also allows for [orElse] to return `null`.
  T? firstWhereSafe(bool Function(T element) test, {T? Function()? orElse}) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }

    if (orElse != null) {
      return orElse();
    }

    return null;
  }
}

/// An internal extension adding utility methods to [Stream].
extension StreamExtension<T> on Stream<T> {
  /// Equivalent to [Iterable.whereType].
  Stream<U> whereType<U>() => where((event) => event is U).cast<U>();
}
