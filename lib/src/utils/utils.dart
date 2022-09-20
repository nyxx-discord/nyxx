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

  /// Append [separator] as the last position.
  /// ```dart
  /// ['Hello', 'Dart'].and(); // Hello and Dart
  /// ```
  String and({String separator = 'and'}) {
    return '${sublist(0, length - 1).join(', ')} $separator $last';
  }
}
