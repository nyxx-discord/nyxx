part of discord;

/// An invite.
class Invite {
  Client _client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  InviteGuild guild;

  /// A mini channel object for the invite's channel.
  InviteChannel channel;

  Invite._new(this._client, this.raw) {
    this.code = raw['code'];
    this.guild = new InviteGuild._new(
        this._client, raw['guild'] as Map<String, dynamic>);
    this.channel = new InviteChannel._new(
        this._client, raw['channel'] as Map<String, dynamic>);
  }
}
