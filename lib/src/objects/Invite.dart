part of discord;

/// An invite.
class Invite extends _BaseObj {
  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  Invite._new(Client client, Map<String, dynamic> data) : super(client) {
    this.code = data['code'];
    this.guild = new InviteGuild._new(
        this._client, data['guild'] as Map<String, dynamic>);
    this.channel = new InviteChannel._new(
        this._client, data['channel'] as Map<String, dynamic>);
  }
}
