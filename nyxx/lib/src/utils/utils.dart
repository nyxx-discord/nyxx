

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
