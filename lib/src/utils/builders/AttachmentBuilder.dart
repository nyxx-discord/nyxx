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
  factory AttachmentBuilder.path(String path, {String? name, bool? spoiler}) =>
      AttachmentBuilder.file(File(path), name: name, spoiler: spoiler);

  /// Create attachment from specified file instance. Name will be automatically extracted from path if no name provided.
  factory AttachmentBuilder.file(File file, {String? name, bool? spoiler}) {
    final bytes = file.readAsBytesSync();
    final fileName = name ?? path_utils.basename(file.path);

    return AttachmentBuilder._new(bytes, fileName, spoiler);
  }

  /// Creates attachment from provided bytes
  factory AttachmentBuilder.bytes(List<int> bytes, String name, {bool? spoiler}) =>
    AttachmentBuilder._new(bytes, name, spoiler);

  /// creates instance of MultipartFile from attachment
  http.MultipartFile getMultipartFile() =>
      http.MultipartFile(_name, Stream.value(_bytes), _bytes.length, filename: _name);

  /// Returns attachment encoded in Data URI scheme format
  /// See: https://discord.com/developers/docs/reference#image-data
  String getBase64() {
    final encodedData = base64Encode(_bytes);
    final extension = path_utils.extension(_name);
    return "data:image/$extension;base64,$encodedData";
  }
}
