part of nyxx;

/// Emitted when invite is creating
class InviteCreatedEvent implements IInviteCreatedEvent {
  /// [IInvite] object of created invite
  @override
  late final IInvite invite;

  /// Creates na instance of [InviteCreatedEvent]
  InviteCreatedEvent(RawApiMap raw, INyxx client) {
    this.invite = Invite(raw["d"] as RawApiMap, client);
  }
}

abstract class IInviteDeletedEvent {
  /// Channel to which invite was pointing
  Cacheable<Snowflake, IGuildChannel> get channel;

  /// Guild where invite was deleted
  Cacheable<Snowflake, IGuild>? get guild;

  /// Code of invite
  String get code;
}

/// Emitted when invite is deleted
class InviteDeletedEvent implements IInviteDeletedEvent {
  /// Channel to which invite was pointing
  @override
  late final Cacheable<Snowflake, IGuildChannel> channel;

  /// Guild where invite was deleted
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Code of invite
  @override
  late final String code;

  /// Creates na instance of [InviteDeletedEvent]
  InviteDeletedEvent(RawApiMap raw, INyxx client) {
    this.code = raw["d"]["code"] as String;
    this.channel = ChannelCacheable(client, Snowflake(raw["d"]["channel_id"]));

    if (raw["d"]["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      this.guild = null;
    }
  }
}
