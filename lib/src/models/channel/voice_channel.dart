import 'package:nyxx/src/models/channel/channel.dart';

class PartialVoiceChannel extends PartialChannel {
  PartialVoiceChannel({required super.id, required super.manager});
}

abstract class VoiceChannel extends PartialVoiceChannel implements Channel {
  final int bitrate;

  final int? userLimit;

  final String? rtcRegion;

  final VideoQualityMode videoQualityMode;

  VoiceChannel({
    required super.id,
    required super.manager,
    required this.bitrate,
    required this.userLimit,
    required this.rtcRegion,
    required this.videoQualityMode,
  });
}

enum VideoQualityMode {
  auto._(1),
  full._(2);

  final int value;

  const VideoQualityMode._(this.value);

  factory VideoQualityMode.parse(int value) => VideoQualityMode.values.firstWhere(
        (mode) => mode.value == value,
        orElse: () => throw FormatException('Unknown VideoQualityMode', value),
      );

  @override
  String toString() => 'VideoQualityMode($value)';
}
