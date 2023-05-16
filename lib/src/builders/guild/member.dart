import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';

class MemberBuilder extends CreateBuilder<Member> {
  final String accessToken;

  final Snowflake userId;

  final String? nick;

  final List<Snowflake>? roleIds;

  final bool? isMute;

  final bool? isDeaf;

  MemberBuilder({
    required this.accessToken,
    required this.userId,
    this.nick,
    this.roleIds,
    this.isMute,
    this.isDeaf,
  });

  @override
  Map<String, Object?> build() => {
        'access_token': accessToken,
        if (nick != null) 'nick': nick,
        if (roleIds != null) 'roles': roleIds!.map((e) => e.toString()).toList(),
        if (isMute != null) 'mute': isMute,
        if (isDeaf != null) 'deaf': isDeaf,
      };
}

class MemberUpdateBuilder extends UpdateBuilder<Member> {
  final String? nick;

  final List<Snowflake>? roleIds;

  final bool? isMute;

  final bool? isDeaf;

  final Snowflake? voiceChannelId;

  final DateTime? communicationDisabledUntil;

  final Flags<MemberFlags>? flags;

  MemberUpdateBuilder({
    this.nick = sentinelString,
    this.roleIds,
    this.isMute,
    this.isDeaf,
    this.voiceChannelId = sentinelSnowflake,
    this.communicationDisabledUntil = sentinelDateTime,
    this.flags,
  });

  @override
  Map<String, Object?> build() => {
        if (!identical(nick, sentinelString)) 'nick': nick,
        if (roleIds != null) 'roles': roleIds!.map((e) => e.toString()).toList(),
        if (isMute != null) 'mute': isMute,
        if (isDeaf != null) 'deaf': isDeaf,
        if (!identical(voiceChannelId, sentinelSnowflake)) 'channel_id': voiceChannelId?.toString(),
        if (!identical(communicationDisabledUntil, sentinelDateTime)) 'communication_disabled_until': communicationDisabledUntil?.toIso8601String(),
        if (flags != null) 'flags': flags!.value,
      };
}

class CurrentMemberUpdateBuilder extends UpdateBuilder<Member> {
  final String? nick;

  CurrentMemberUpdateBuilder({this.nick = sentinelString});

  @override
  Map<String, Object?> build() => {
        if (!identical(nick, sentinelString)) 'nick': nick,
      };
}
