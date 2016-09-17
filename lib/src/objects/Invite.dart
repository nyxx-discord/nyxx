import '../objects.dart';

/// An invite.
class Invite {
  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  Invite(Map data) {
    this.code = data['code'];
    this.guild = new InviteGuild(data['guild']);
    this.channel = new InviteChannel(data['channel']);
  }
}
