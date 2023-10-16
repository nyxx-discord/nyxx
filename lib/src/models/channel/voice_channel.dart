import 'package:nyxx/src/models/channel/channel.dart';

/// A voice channel.
abstract class VoiceChannel implements Channel {
  /// The bitrate of the channel in bits/s.
  int get bitrate;

  /// The maximum number of users that can join this channel at once.
  int? get userLimit;

  /// The ID of the voice region for this channel, or automatic if `null`.
  String? get rtcRegion;

  /// The [VideoQualityMode] for cameras in this channel.
  VideoQualityMode get videoQualityMode;
}

/// The quality mode of cameras in a [VoiceChannel].
enum VideoQualityMode {
  /// Automatic.
  auto._(1),

  /// 720p.
  full._(2);

  /// The value of this [VideoQualityMode].
  final int value;

  const VideoQualityMode._(this.value);

  /// Parse a [VideoQualityMode] from an [int].
  ///
  /// [value] must be a valid [VideoQualityMode].
  factory VideoQualityMode.parse(int value) => VideoQualityMode.values.firstWhere(
        (mode) => mode.value == value,
        orElse: () => throw FormatException('Unknown VideoQualityMode', value),
      );

  @override
  String toString() => 'VideoQualityMode($value)';
}
