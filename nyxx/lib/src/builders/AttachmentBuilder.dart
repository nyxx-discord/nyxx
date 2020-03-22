part of nyxx;

/// Helper for sending attachment in messages. Allows to create attachment from path, [File] or bytes.
class AttachmentBuilder {
  late final File? _file;
  late final List<int>? _bytes;
  late final int _length;

  late String _name;
  late bool _spoiler;

  /// Open file at [path] then read it's contents and prepare to send. Name will be automatically extracted from path if no name provided.
  AttachmentBuilder.path(String path, {String? name, bool spoiler = false})
      : this.file(File(path), name: name, spoiler: spoiler);

  /// Create attachment from specified file instance. Name will be automatically extracted from path if no name provided.
  AttachmentBuilder.file(this._file, {String? name, bool spoiler = false}) {
    this._length = this._file!.lengthSync();
    this._spoiler = spoiler;

    if (this._length > (8 * 1024 * 1024)) {
      throw new Exception(
          "File [${_name}] is to big to be sent. (8MB file size limit)");
    }

    if (name != null) {
      this._name = name;
    } else {
      this._name = Uri.file(this._file!.path).toString().split("/").last;
    }

    if (this._spoiler) {
      this._name = "SPOILER_${this._name}";
    }
  }

  /// Creates attachment from provided bytes
  AttachmentBuilder.bytes(this._bytes, this._name, {bool spoiler = false}) {
    this._length = _bytes!.length;
    this._spoiler = spoiler;

    if (this._length > (8 * 1024 * 1024)) {
      throw new Exception(
          "File [${_name}] is to big to be sent. (8MB file size limit)");
    }

    if (this._spoiler) {
      this._name = "SPOILER_${this._name}";
    }
  }

  Stream<List<int>> _openRead() => this._file != null
      ? this._file!.openRead()
      : Stream.fromIterable([this._bytes]);

  // creates instance of MultipartFile
  transport.MultipartFile _asMultipartFile() =>
      transport.MultipartFile(_openRead(), this._length, filename: _name);
}
