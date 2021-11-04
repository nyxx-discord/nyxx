part of nyxx;

/// Create a new sticker for the guild
class StickerBuilder implements Builder {
  /// Name of the sticker (2-30 characters)
  late String name;

  /// Description of the sticker (empty or 2-100 characters)
  late String description;

  /// The Discord name of a unicode emoji representing the sticker's expression (2-200 characters)
  late String tags;

  late List<int> _bytes;

  StickerBuilder._new(this._bytes, this.name, this.description, this.tags);

  /// Open file at [path] then read it's contents and prepare to send. Name will be automatically extracted from path if no name provided.
  factory StickerBuilder.path(String path, {required String name, required String description, required String tags}) =>
      StickerBuilder.file(File(path), name: name, description: description, tags: tags);

  /// Create attachment from specified file instance. Name will be automatically extracted from path if no name provided.
  factory StickerBuilder.file(File file, {required String name, required String description, required String tags}) {
    final bytes = file.readAsBytesSync();

    return StickerBuilder._new(bytes, name, description, tags);
  }

  /// Creates attachment from provided bytes
  factory StickerBuilder.bytes(List<int> bytes, {required String name, required String description, required String tags}) =>
      StickerBuilder._new(bytes, name, description, tags);

  http.MultipartFile get _multipartFile =>
      http.MultipartFile("file", Stream.value(_bytes), _bytes.length);

  @override
  RawApiMap build() => {
    "name": this.name,
    "description": this.description,
    "tags": this.tags
  };
}
