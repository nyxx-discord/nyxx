import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class Attachment with ToStringHelper {
  final Snowflake id;

  final String fileName;

  final String? description;

  final String? contentType;

  final int size;

  final Uri url;

  final Uri proxiedUrl;

  final int? height;

  final int? width;

  final bool ephemeral;

  Attachment({
    required this.id,
    required this.fileName,
    required this.description,
    required this.contentType,
    required this.size,
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
    required this.ephemeral,
  });
}
