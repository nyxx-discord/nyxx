part of nyxx;

/// Represents invite to guild.
class Invite {
  /// The invite's code.
  late final String code;

  /// A mini guild object for the invite's guild.
  late final Guild? guild;

  /// A mini channel object for the invite's channel.
  late final GuildChannel channel;

  /// Returns url invite
  String get url => "https://discord.gg/$code";

  /// Date when invite was created
  late final DateTime createdAt;

  /// True if invite is temporary
  late final bool temporary;

  /// Number of uses of this invite
  late final int uses;

  /// Max number of uses of this invite
  late final int maxUses;

  /// User who created this invite
  late final User? inviter;

  /// Reference to bot instance
  Nyxx client;

  Invite._new(Map<String, dynamic> raw, this.client) {
    this.code = raw['code'] as String;
    this.guild = client.guilds[Snowflake(raw['guild']['id'] as String)];

    this.channel = client.channels[Snowflake(raw['channel']['id'] as String)]
        as GuildChannel;

    this.createdAt = DateTime.parse(raw['created_at'] as String);
    this.temporary = raw['temporary'] as bool;
    this.uses = raw['uses'] as int;
    this.maxUses = raw['max_uses'] as int;

    this.inviter = client.users[Snowflake(raw['inviter']['id'] as String)];
  }

  /// Deletes this Invite.
  Future<void> delete({String auditReason = ""}) async {
    await client._http.send('DELETE', '/invites/$code', reason: auditReason);
  }
}
