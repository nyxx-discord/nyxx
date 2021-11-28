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

  Stream<List<E>> chunk(int chunkSize) async* {
    final len = length;
    for (var i = 0; i < len; i += chunkSize) {
      final size = i + chunkSize;
      yield sublist(i, size > len ? len : size);
    }
  }
}
