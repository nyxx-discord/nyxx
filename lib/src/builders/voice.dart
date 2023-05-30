import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/voice/voice_state.dart';

class VoiceStateUpdateBuilder extends UpdateBuilder<VoiceState> {
  final Snowflake? channelId;

  final bool? suppress;

  VoiceStateUpdateBuilder({this.channelId, this.suppress});

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId!.toString(),
        if (suppress != null) 'suppress': suppress,
      };
}

class CurrentUserVoiceStateUpdateBuilder extends VoiceStateUpdateBuilder {
  final DateTime? requestToSpeakTimeStamp;

  CurrentUserVoiceStateUpdateBuilder({super.channelId, super.suppress, this.requestToSpeakTimeStamp = sentinelDateTime});

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (!identical(requestToSpeakTimeStamp, sentinelDateTime)) 'request_to_speak_timestamp': requestToSpeakTimeStamp?.toIso8601String(),
      };
}
