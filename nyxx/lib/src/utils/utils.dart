part of nyxx;

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

  /// Returns String with base64 encoded image data for API upload
  static String? getBase64UploadString({File? file, List<int>? fileBytes, String? base64EncodedFile, String? fileExtension}) {
    String base64Encoded;
    if (file != null) {
      base64Encoded = base64Encode(file.readAsBytesSync());
    } else if (fileBytes != null) {
      base64Encoded = base64Encode(fileBytes);
    } else if (base64EncodedFile != null) {
      base64Encoded = base64EncodedFile;
    } else {
      return null;
    }

    final extension = file != null ? path_utils.extension(file.path).replaceAll(".", "") : fileExtension;
    return "data:image/$extension;base64,$base64Encoded";
  }
}
