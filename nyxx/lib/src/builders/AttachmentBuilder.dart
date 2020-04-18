part of nyxx;

/// Helper for sending attachment in messages. Allows to create attachment from path, [File] or bytes.
class AttachmentBuilder {
  final List<int> _bytes;

  late String _name;
  late bool _spoiler;

  AttachmentBuilder._new(this._bytes, this._name, bool? spoiler) {
    this._spoiler = spoiler ?? false;

    if (_spoiler) {
      _name = "SPOILER_$_name";
    }
  }

  /// Generate [Attachment] string
  String get attachUrl => "attachment://$_name";

  /// Open file at [path] then read it's contents and prepare to send. Name will be automatically extracted from path if no name provided.
  factory AttachmentBuilder.path(String path, {String? name, bool? spoiler}) {
    var bytes = File(path).readAsBytesSync();
    var fileName = name == null ? path_utils.basename(path) : name;

    return new AttachmentBuilder._new(bytes, fileName, spoiler);
  }

  /// Create attachment from specified file instance. Name will be automatically extracted from path if no name provided.
  factory AttachmentBuilder.file(File file, {String? name, bool? spoiler}) {
    var bytes = file.readAsBytesSync();
    var fileName = name == null ? path_utils.basename(file.path) : name;

    return AttachmentBuilder._new(bytes, fileName, spoiler);
  }

  /// Creates attachment from provided bytes
  factory AttachmentBuilder.bytes(List<int> bytes, String name,
      {bool? spoiler}) {
    return AttachmentBuilder._new(bytes, name, spoiler);
  }

  // creates instance of MultipartFile
  transport.MultipartFile _asMultipartFile() =>
      transport.MultipartFile(Stream.value(_bytes), _bytes.length,
          filename: _name);
}
