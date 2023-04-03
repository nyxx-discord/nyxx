import 'package:nyxx/src/models/channel/channel.dart';

abstract class VoiceChannel implements Channel {
  int get bitrate;

  int? get userLimit;

  String? get rtcRegion;

  VideoQualityMode get videoQualityMode;
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
