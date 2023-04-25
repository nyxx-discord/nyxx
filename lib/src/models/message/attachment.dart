import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template attachment}
/// An attachment in a [Message].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#attachment-object
/// {@endtemplate}
class Attachment with ToStringHelper {
  /// This attachment's ID.
  final Snowflake id;

  /// The name of the attached file.
  final String fileName;

  /// A description of the attached file.
  final String? description;

  /// The content type of the attached file.
  final String? contentType;

  /// The size of the attached file in bytes.
  final int size;

  /// A URL from which the attached file can be downloaded.
  final Uri url;

  /// A proxied URL from which the attached file can be downloaded.
  final Uri proxiedUrl;

  /// If the file is an image, the height of the image in pixels.
  final int? height;

  /// If the file is an image, the width of the image in pixels.
  final int? width;

  /// Whether this attachment is ephemeral.
  final bool isEphemeral;

  /// {@macro attachment}
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
    required this.isEphemeral,
  });
}
