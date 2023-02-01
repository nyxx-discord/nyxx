import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/builder.dart';
import 'package:nyxx/src/core/user/member_flags.dart';

class MemberBuilder implements Builder {
  /// Value to set user's nickname to
  String? nick;

  /// Array of role ids the member is assigned
  List<Snowflake>? roles;

  /// Whether the user is muted in voice channels.
  bool? mute;

  /// Whether the user is deafened in voice channels.
  bool? deaf;

  /// Id of channel to move user to (if they are connected to voice)
  Snowflake? channel = Snowflake.zero();

  /// When the user's timeout will expire and the user will be able to communicate in the guild again (up to 28 days in the future), set to null to remove timeout
  DateTime? timeoutUntil = DateTime.fromMillisecondsSinceEpoch(0);

  /// The [flags](https://discord.com/developers/docs/resources/guild#guild-member-object-guild-member-flags) to add/remove from the member.
  PatchableMemberFlags? flags;

  @override
  RawApiMap build() => {
        if (nick != null) 'nick': nick,
        if (roles != null) 'roles': roles!.map((e) => e.toString()).toList(),
        if (mute != null) 'mute': mute,
        if (deaf != null) 'deaf': deaf,
        if (channel != Snowflake.zero()) 'channel_id': channel?.toString(),
        if (timeoutUntil?.millisecondsSinceEpoch != 0) 'communication_disabled_until': timeoutUntil?.toIso8601String(),
        if (flags != null) 'flags': flags!.toBitField(),
      };
}
