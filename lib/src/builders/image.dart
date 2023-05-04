import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class ImageBuilder {
  final List<int> data;
  final String format;

  const ImageBuilder({required this.data, required this.format});

  const ImageBuilder.png(this.data) : format = 'png';

  const ImageBuilder.jpeg(this.data) : format = 'jpeg';

  const ImageBuilder.gif(this.data) : format = 'gif';

  static Future<ImageBuilder> fromFile(File file, {String? format}) async {
    format ??= p.extension(file.path);

    const formats = {
      'png': 'png',
      'jpeg': 'jpeg',
      'jpg': 'jpeg',
      'gif': 'gif',
    };

    final actualFormat = formats[format];

    if (actualFormat == null) {
      throw ArgumentError('Invalid format $format');
    }

    final data = await file.readAsBytes();

    return ImageBuilder(data: data, format: actualFormat);
  }

  String build() => 'data:image/$format;base64,${base64Encode(data)}';
}
