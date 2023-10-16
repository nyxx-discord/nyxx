import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

class VoiceStateUpdateBuilder extends UpdateBuilder<VoiceState> {
  Snowflake? channelId;

  bool? suppress;

  VoiceStateUpdateBuilder({this.channelId, this.suppress});

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId!.toString(),
        if (suppress != null) 'suppress': suppress,
      };
}

class CurrentUserVoiceStateUpdateBuilder extends VoiceStateUpdateBuilder {
  DateTime? requestToSpeakTimeStamp;

  CurrentUserVoiceStateUpdateBuilder({super.channelId, super.suppress, this.requestToSpeakTimeStamp = sentinelDateTime});

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (!identical(requestToSpeakTimeStamp, sentinelDateTime)) 'request_to_speak_timestamp': requestToSpeakTimeStamp?.toIso8601String(),
      };
}

class GatewayVoiceStateBuilder extends CreateBuilder<VoiceState> {
  Snowflake? channelId;

  bool isMuted;

  bool isDeafened;

  GatewayVoiceStateBuilder({required this.channelId, required this.isMuted, required this.isDeafened});

  @override
  Map<String, Object?> build() => {
        'channel_id': channelId?.toString(),
        'self_mute': isMuted,
        'self_deaf': isDeafened,
      };
}
