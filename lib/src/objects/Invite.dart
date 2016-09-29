import '../../discord.dart';

/// An invite.
class Invite {
  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  /// Constructs a new [Invite].
  Invite(Map<String, dynamic> data) {
    this.code = data['code'];
    this.guild = new InviteGuild(data['guild'] as Map<String, dynamic>);
    this.channel = new InviteChannel(data['channel'] as Map<String, dynamic>);
  }
}
