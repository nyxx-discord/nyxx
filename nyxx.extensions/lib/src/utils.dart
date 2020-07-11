import "dart:async";

class StreamUtils {
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
}

class StringUtils {
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
}