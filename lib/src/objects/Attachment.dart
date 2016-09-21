import '../../objects.dart';

/// A message attachment.
class Attachment {
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

  Attachment(Map data) {
    this.id = data['id'];
    this.filename = data['filename'];
    this.url = data['url'];
    this.proxyUrl = data['proxyUrl'];
    this.size = data['size'];
    this.height = data['height'];
    this.width = data['width'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;
  }
}
