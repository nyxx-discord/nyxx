part of nyxx;

class Utils {
  // Divides list into equal pieces
  static Stream<List<T>> chunk<T>(List<T> list, int chunkSize) async* {
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i + chunkSize;
      yield list.sublist(i, size > len ? len : size);
    }
  }

  static String getFileExtension(String path) {
    return path_utils.Context(style: path_utils.Style.platform).extension(path);
  }
}
