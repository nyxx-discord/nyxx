part of nyxx.interactivity;

class _Utils {
  /// Merges list of stream into one stream
  static Stream<T> merge<T>(List<Stream<T>> streams) {
    var _open = streams.length;
    final streamController = StreamController<T>();
    for (final stream in streams) {
      stream.listen(streamController.add)
        ..onError(streamController.addError)
        ..onDone(() {
          if (--_open == 0) {
            streamController.close();
          }
        });
    }
    return streamController.stream;
  }

  /// Splits string based on desired length
  static Iterable<String> split(String str, int length) sync* {
    var last = 0;
    while (last < str.length && ((last + length) < str.length)) {
      yield str.substring(last, last + length);
      last += length;
    }
    yield str.substring(last, str.length);
  }

  /// Splits string based on number of wanted substrings
  static Iterable<String> splitEqually(String str, int pieces) {
    final len = (str.length / pieces).round();

    return split(str, len);
  }

  /// Partition list into chunks
  static Iterable<List<T>> partition<T>(List<T> lst, int len) sync* {
    for (var i = 0; i < lst.length; i += len) {
      yield lst.sublist(i, i + len);
    }
  }

  /// Divides list into equal pieces
  static Stream<List<T>> chunk<T>(List<T> list, int chunkSize) async* {
    final len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      final size = i + chunkSize;
      yield list.sublist(i, size > len ? len : size);
    }
  }
}
