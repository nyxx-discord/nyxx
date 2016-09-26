import '../../discord.dart';

/// A message attachment.
class Attachment {
  /// A map of all of the properties.
  Map<String, dynamic> map = <String, dynamic>{};

  /// The attachment's ID
  String id;

  /// The attachment's filename.
  String filename;

  /// The attachment's URL.
  String url;

  /// The attachment's proxy URL.
  String proxyUrl;

  /// The attachment's file size.
  int size;

  /// The attachment's height, if an image.
  int height;

  /// The attachment's width, if an image,
  int width;

  /// A timestamp for when the message was created.
  double createdAt;

  /// Constructs a new [Attachment].
  Attachment(Map<String, dynamic> data) {
    this.id = data['id'];
    this.map['id'] = this.id;

    this.filename = data['filename'];
    this.map['filename'] = this.filename;

    this.url = data['url'];
    this.map['url'] = this.url;

    this.proxyUrl = data['proxyUrl'];
    this.map['proxyUrl'] = this.proxyUrl;

    this.size = data['size'];
    this.map['size'] = this.size;

    this.height = data['height'];
    this.map['height'] = this.height;

    this.width = data['width'];
    this.map['width'] = this.width;

    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
    this.map['createdAt'] = this.createdAt;

  }
}
