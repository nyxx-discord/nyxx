import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template attachment}
/// An attachment in a [Message].
///
/// Note that although this class implements [CdnAsset], not all operations are supported. Notably, [CdnFormat]s and sizes are not supported.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#attachment-object
/// {@endtemplate}
class Attachment with ToStringHelper implements CdnAsset {
  /// The manager for this [Attachment].
  final MessageManager manager;

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
  @override
  final Uri url;

  /// A proxied URL from which the attached file can be downloaded.
  final Uri proxiedUrl;

  /// If the file is an image, the height of the image in pixels.
  final int? height;

  /// If the file is an image, the width of the image in pixels.
  final int? width;

  /// Whether this attachment is ephemeral.
  final bool isEphemeral;

  /// The duration of this audio file for voice messages.
  final Duration? duration;

  /// A sampled waveform for voice messages.
  final List<int>? waveform;

  /// This attachment's flags.
  final AttachmentFlags? flags;

  /// For Clips, users who were in the stream.
  final List<User>? clipParticipants;

  /// For Clips, when the clip was created.
  final DateTime? clipCreatedAt;

  /// for Clips, the application in the stream if recognized.
  final Application? application;

  @override
  Nyxx get client => manager.client;

  @override
  String get hash => fileName;

  @override
  HttpRoute get base => HttpRoute()..parts.addAll(proxiedUrl.pathSegments.take(proxiedUrl.pathSegments.length - 1).map((part) => HttpRoutePart(part)));

  @override
  CdnFormat get defaultFormat => throw UnsupportedError('Cannot get attachment format');

  @override
  bool get isAnimated => flags?.hasIsAnimated ?? false;

  /// {@macro attachment}
  /// @nodoc
  Attachment({
    required this.id,
    required this.manager,
    required this.fileName,
    required this.description,
    required this.contentType,
    required this.size,
    required this.url,
    required this.proxiedUrl,
    required this.height,
    required this.width,
    required this.isEphemeral,
    required this.duration,
    required this.waveform,
    required this.flags,
    required this.application,
    required this.clipCreatedAt,
    required this.clipParticipants,
  });

  @override
  Future<Uint8List> fetch({CdnFormat? format, int? size}) async {
    if (format != null || size != null) {
      throw UnsupportedError('Cannot specify attachment format or size');
    }

    final response = await client.httpHandler.httpClient.get(url);
    return response.bodyBytes;
  }

  @override
  Stream<List<int>> fetchStreamed({CdnFormat? format, int? size}) async* {
    if (format != null || size != null) {
      throw UnsupportedError('Cannot specify attachment format or size');
    }

    final response = await client.httpHandler.httpClient.send(Request('GET', url));
    yield* response.stream;
  }
}

/// The flags for an [Attachment].
///
/// External References:
/// * Discord API Reference: https://discord.com/developers/docs/resources/message#attachment-object-attachment-flags
class AttachmentFlags extends Flags<AttachmentFlags> {
  /// The attachment is a [Clip from a stream](https://support.discord.com/hc/en-us/articles/16861982215703).
  static const isClip = Flag<AttachmentFlags>.fromOffset(0);

  /// The attachment is the thumbnail of a thread in a media channel, displayed in the grid but not on the message.
  static const isThumbnail = Flag<AttachmentFlags>.fromOffset(1);

  /// The attachment is a remix.
  static const isRemix = Flag<AttachmentFlags>.fromOffset(2);

  /// The attachment was marked as a spoiler and is blurred until clicked.
  static const isSpoiler = Flag<AttachmentFlags>.fromOffset(3);

  /// The attachment was flagged as [sensitive content](https://support.discord.com/hc/en-us/articles/18210995019671).
  static const containsExplicitMedia = Flag<AttachmentFlags>.fromOffset(4);

  /// The attachment is an animated image
  static const isAnimated = Flag<AttachmentFlags>.fromOffset(5);

  /// Whether this set of flags has the [isClip] flag.
  bool get isAClip => has(isClip);

  /// Whether this set of flags has the [isThumbnail] flag.
  bool get isAThumbnail => has(isThumbnail);

  /// Whether this set of flags has the [isRemix] flag.
  bool get isARemix => has(isRemix);

  /// Whether this set of flags has the [isSpoiler] flag.
  bool get isASpoiler => has(isSpoiler);

  /// Whether this set of flags has the [containsExplicitMedia] flag.
  bool get doContainsExplicitMedia => has(containsExplicitMedia);

  /// Whether this set of flags has the [isAnimated] flag.
  bool get hasIsAnimated => has(isAnimated);

  /// Create a new [AttachmentFlags].
  const AttachmentFlags(super.value);
}
