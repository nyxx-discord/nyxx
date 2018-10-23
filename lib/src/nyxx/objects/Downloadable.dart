part of nyxx;

/// Provides abstraction for objects which can be downloaded to bytes or [File]
abstract class Downloadable {
  /// Download object to [List] of bytes
  Future<List<int>> download();

  /// Download object, and write downloaded contents to [file], then return updated [File] object.
  Future<File> downloadFile(File file);
}