part of nyxx;

/// Represents channel which is part of guild.
abstract class GuildChannel implements Channel, GuildEntity {
  /// The channel's name.
  String name;

  @override

  /// The guild that the channel is in.
  Guild guild;

  /// The channel's position in the channel list.
  int position;

  /// Parent channel id
  CategoryChannel parentChannel;

  /// Indicates if channel is nsfw
  bool nsfw;

  /// Permissions overwrites for channel.
  List<PermissionsOverrides> permissions;

  // Initializes Guild channel
  void _initialize(Map<String, dynamic> raw, Guild guild) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.guild = guild;

    if (raw['parent_id'] != null) {
      this.parentChannel =
          client.channels[Snowflake(raw['parent_id'])] as CategoryChannel;
    }

    this.nsfw = raw['nsfw'] as bool;

    if (raw['permission_overwrites'] != null) {
      permissions = List();
      raw['permission_overwrites'].forEach((o) {
        permissions.add(PermissionsOverrides._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Returns effective permissions for [member] to this channel including channel overrides.
  Permissions effectivePermissions(Member member) {
    if (member.guild == null || member.guild != this.guild)
      return Permissions.empty();

    if (member.guild.owner == member)
      return Permissions.fromInt(PermissionsConstants.allPermissions);

    var rawMemberPerms = member.effectivePermissions.raw;

    if (utils.isApplied(rawMemberPerms, PermissionsConstants.administrator))
      return Permissions.fromInt(PermissionsConstants.allPermissions);

    final overrides = utils.getOverrides(member, this);
    rawMemberPerms =
        utils.apply(rawMemberPerms, overrides.first, overrides.last);

    return utils.isApplied(rawMemberPerms, PermissionsConstants.viewChannel)
        ? Permissions.fromInt(rawMemberPerms)
        : Permissions.empty();
  }

  /// Returns effective permissions for [role] to this channel including channel overrides.
  Permissions effectivePermissionForRole(Role role) {
    if (role.guild == null || role.guild != this.guild)
      return Permissions.empty();

    var permissions = role.permissions.raw | guild.everyoneRole.permissions.raw;

    try {
      var over =
          this.permissions.firstWhere((f) => f.id == guild.everyoneRole.id);

      permissions &= ~over.deny;
      permissions |= over.allow;
    } catch (e) {}

    try {
      var over = this.permissions.firstWhere((f) => f.id == role.id);

      permissions &= ~over.deny;
      permissions |= over.allow;
    } catch (e) {}

    return Permissions.fromInt(permissions);
  }

  /// Creates new [Invite] for [Channel] and returns it's instance
  ///
  /// ```
  /// var inv = await chan.createInvite(maxUses: 2137);
  /// ```
  Future<Invite> createInvite(
      {int maxAge = 0,
      int maxUses = 0,
      bool temporary = false,
      bool unique = false,
      String auditReason = ""}) async {
    Map<String, dynamic> params = Map<String, dynamic>();

    params['max_age'] = maxAge;
    params['maxUses'] = maxUses;
    params['temporary'] = temporary;
    params['unique'] = unique;

    final HttpResponse r = await client._http.send(
        'POST', "/channels/$id/invites",
        body: params, reason: auditReason);

    return Invite._new(r.body as Map<String, dynamic>, client);
  }

  /// Fetches and returns all channel's [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Future<Map<String, Invite>> getChannelInvites() async {
    final HttpResponse r =
        await client._http.send('GET', "/channels/$id/invites");

    Map<String, Invite> invites = Map();
    for (Map<String, dynamic> val in r.body.values.first) {
      invites[val["code"] as String] = Invite._new(val, client);
    }

    return invites;
  }

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermission(
      PermissionsBuilder perms, SnowflakeEntity id,
      {String auditReason = ""}) async {
    if (!(id is Role) || !(id is User))
      throw Exception("The `id` property must be either Role or User");

    await client._http.send(
        "PUT", "/channels/${this.id}/permissions/${id.toString()}",
        body: perms._build()._build(), reason: auditReason);
  }

  /// Deletes permission overwrite for given User or Role [id]
  /// Throws if [id] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity id,
      {String auditReason = ""}) async {
    if (!(id is Role) || !(id is User))
      throw Exception("`id` property must be either Role or User");

    await client._http.send("POST", "/channels/${this.id}/permissions/$id",
        reason: auditReason);
  }
}
