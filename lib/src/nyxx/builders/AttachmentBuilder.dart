part of nyxx;

class AttachmentBuilder {
  File _file;
  List<int> _bytes;
  int _length = 0;

  /// Attachment name
  String name;

  /// True if attachment should be treated as spoiler
  bool spoiler;

  AttachmentBuilder.path(String path, {String name, bool spoiler = false}) : this.file(File(path), name: name, spoiler: spoiler);

  AttachmentBuilder.file(this._file, {this.name, this.spoiler = false}) {
    this._length = this._file.lengthSync();

    if(this._length > (8 * 1024 * 1024))
      throw new Exception("File [${name}] is to big to be sent. (8MB file size limit)");

    if(this._file != null && this.name == null)
      this.name = Uri.file(this._file.path).toString().split("/").last;

    if(this.spoiler)
      this.name = "SPOILER_${this.name}";
  }

  AttachmentBuilder.bytes(this._bytes, this.name, {this.spoiler = false}) {
    this._length = _bytes.length;

    if(this._length > (8 * 1024 * 1024))
      throw new Exception("File [${name}] is to big to be sent. (8MB file size limit)");

    if(this.spoiler)
      this.name = "SPOILER_${this.name}";
  }

  Stream<List<int>> _openRead() => this._file != null ? this._file.openRead() : Stream.fromIterable([this._bytes]);

  transport.MultipartFile _asMultipartFile() {
    return transport.MultipartFile(_openRead(), this._length, filename: name ?? "WHY THE FUCK YOU PASS NULL AS FILENAME");
  }
}