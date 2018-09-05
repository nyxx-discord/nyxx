part of nyxx;

/// An invite.
class Invite {
  /// The [Nyxx] object.
  Nyxx client;

  /// The raw object returned by the API
  Map<String, dynamic> raw;

  /// The invite's code.
  String code;

  /// A mini guild object for the invite's guild.
  Guild guild;

  /// A mini channel object for the invite's channel.
  GuildChannel channel;

  /// Returns url invite
  String get url => "https://discord.gg/$code";

  Invite._new(this.client, this.raw) {
    this.code = raw['code'] as String;
    this.guild = client.guilds[Snowflake(raw['guild']['id'] as String)];
    this.channel = client.channels[Snowflake(raw['channel']['id'] as String)]
        as GuildChannel;
  }

  /// Deletes this Invite.
  Future<void> delete({String auditReason = ""}) async {
    await this
        .client
        .http
        .send('DELETE', '/invites/$code', reason: auditReason);
  }
}
