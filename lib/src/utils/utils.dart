/// Collection of misc util functions
class Utils {
  /// Divides list into equal pieces
  static Stream<List<T>> chunk<T>(List<T> list, int chunkSize) async* {
    final len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      final size = i + chunkSize;
      yield list.sublist(i, size > len ? len : size);
    }
  }
}

extension ListSafeFirstWhere<E> on List<E> {
  E? firstWhereSafe(bool Function(E element) test, {E? Function()? orElse}) {
    try {
      return firstWhere(test);
    } on StateError {
      if (orElse != null) {
        return orElse();
      }

      return null;
    }
  }
}
