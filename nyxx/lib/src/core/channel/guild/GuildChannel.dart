part of nyxx;

/// Represents channel within [Guild]. Shares logic for both [TextGuildChannel] and [VoiceGuildChannel].
abstract class GuildChannel extends IChannel {
  /// The channel"s name.
  late final String name;

  /// Relative position of channel in context of channel list
  late final int position;

  /// Id of [Guild] that the channel is in.
  late final Cacheable<Snowflake, Guild> guild;

  /// Id of parent channel
  late final Cacheable<Snowflake, GuildChannel>? parentChannel;

  /// Indicates if channel is nsfw
  late final bool isNsfw;

  /// Permission override for channel
  late final List<PermissionsOverrides> permissionOverrides;

  GuildChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId]) : super._new(client, raw) {
    this.name = raw["name"] as String;
    this.position = raw["position"] as int;

    if (raw["guild_id"] != null) {
      this.guild = _GuildCacheable(client, Snowflake(raw["guild_id"]));
    } else if (guildId != null) {
      this.guild = _GuildCacheable(client, guildId);
    } else {
      throw Exception("Cannot initialize instance of GuildChannelNex due missing `guild_id` in json payload and/or missing optional guildId parameter. Report this issue to developer");
    }

    if (raw["parent_id"] != null) {
      this.parentChannel = _ChannelCacheable(client, Snowflake(raw["parent_id"]));
    } else {
      this.parentChannel = null;
    }

    this.isNsfw = raw["nsfw"] as bool? ?? false;

    this.permissionOverrides = [
      if (raw["permission_overwrites"] != null)
        for (var obj in raw["permission_overwrites"])
          PermissionsOverrides._new(obj as Map<String, dynamic>)
    ];
  }

  /// Returns effective permissions for [member] to this channel including channel overrides.
  Future<Permissions> effectivePermissions(Member member) async {
    if (member.guild != this.guild) {
      return Permissions.empty();
    }

    final owner = await member.guild.getOrDownload();
    if (owner == member) {
      return Permissions.fromInt(PermissionsConstants.allPermissions);
    }

    var rawMemberPerms = (await member.effectivePermissions).raw;

    if (PermissionsUtils.isApplied(rawMemberPerms, PermissionsConstants.administrator)) {
      return Permissions.fromInt(PermissionsConstants.allPermissions);
    }

    final overrides = PermissionsUtils.getOverrides(member, this);
    rawMemberPerms = PermissionsUtils.apply(rawMemberPerms, overrides.first, overrides.last);

    return PermissionsUtils.isApplied(rawMemberPerms, PermissionsConstants.viewChannel)
        ? Permissions.fromInt(rawMemberPerms)
        : Permissions.empty();
  }

  /// Returns effective permissions for [role] to this channel including channel overrides.
  Future<Permissions> effectivePermissionForRole(Role role) async {
    if (role.guild != this.guild) {
      return Permissions.empty();
    }

    final guildInstance = await this.guild.getOrDownload();

    var permissions = role.permissions.raw | guildInstance.everyoneRole.permissions.raw;

    // TODO: NNBD: try-catch in where
    try {
      final overEveryone = this.permissionOverrides.firstWhere((f) => f.id == guildInstance.everyoneRole.id);

      permissions &= ~overEveryone.deny;
      permissions |= overEveryone.allow;
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } on Exception {}

    try {
      final overRole = this.permissionOverrides.firstWhere((f) => f.id == role.id);

      permissions &= ~overRole.deny;
      permissions |= overRole.allow;
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } on Exception {}

    return Permissions.fromInt(permissions);
  }

  /// Fetches and returns all channel"s [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Stream<InviteWithMeta> fetchChannelInvites() =>
      client._httpEndpoints.fetchChannelInvites(this.id);

  /// Allows to set or edit permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermissions(PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) =>
      client._httpEndpoints.editChannelPermissions(this.id, perms, entity, auditReason: auditReason);

  /// Allows to edit or set channel permission overrides.
  Future<void> editChannelPermissionOverrides(PermissionOverrideBuilder permissionBuilder, {String? auditReason}) =>
      client._httpEndpoints.editChannelPermissionOverrides(this.id, permissionBuilder, auditReason: auditReason);

  /// Deletes permission overwrite for given User or Role [entity]
  /// Throws if [entity] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity entity, {String? auditReason}) =>
      client._httpEndpoints.deleteChannelPermission(this.id, entity, auditReason: auditReason);

  /// Creates new [Invite] for [IChannel] and returns it"s instance
  ///
  /// ```
  /// var invite = await channel.createInvite(maxUses: 2137);
  /// ```
  Future<Invite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) =>
      client._httpEndpoints.createInvite(this.id, maxAge: maxAge, maxUses: maxUses, temporary: temporary, unique: unique, auditReason: auditReason);
}
