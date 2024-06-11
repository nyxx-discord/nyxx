import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/utils/enum_like.dart';

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
final class VideoQualityMode extends EnumLike<int> {
  /// Automatic.
  static const VideoQualityMode auto = VideoQualityMode._(1);

  /// 720p.
  static const VideoQualityMode full = VideoQualityMode._(2);

  static const List<VideoQualityMode> values = [auto, full];

  const VideoQualityMode._(super.value);

  factory VideoQualityMode.parse(int value) => parseEnum(values, value);
}
