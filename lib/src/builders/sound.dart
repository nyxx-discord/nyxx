import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class SoundBuilder {
  List<int> data;
  String format;

  SoundBuilder({required this.data, required this.format});

  SoundBuilder.mp3(this.data) : format = 'mpeg';

  SoundBuilder.ogg(this.data) : format = 'ogg';

  static Future<SoundBuilder> fromFile(File file, {String? format}) async {
    format ??= p.extension(file.path);

    const formats = {
      'mp3': 'mpeg',
      'mpeg': 'mpeg',
      'ogg': 'ogg',
    };

    final actualFormat = formats[format];

    if (actualFormat == null) {
      throw ArgumentError.value(format, 'format', 'Unsupported format');
    }

    final data = await file.readAsBytes();

    return SoundBuilder(data: data, format: actualFormat);
  }

  List<int> buildRawData() => data;

  String buildDataString() => 'data:audio/$format;base64,${base64Encode(data)}';
}
