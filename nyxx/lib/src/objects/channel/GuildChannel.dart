part of nyxx;

/// Represents channel which is part of guild.
mixin GuildChannel implements Channel, GuildEntity {
  /// The channel's name.
  late String name;

  @override

  /// The guild that the channel is in.
  late Guild guild;

  /// The channel's position in the channel list.
  late int position;

  /// Parent channel id
  CategoryChannel? parentChannel;

  /// Indicates if channel is nsfw
  late bool nsfw;

  /// Permissions overwrites for channel.
  late final List<PermissionsOverrides> permissions;

  /// Returns list of [Member] objects who can see this channel
  Iterable<Member> get users => this.guild.members.values.where((member) => this
      .effectivePermissions(member)
      .hasPermission(PermissionsConstants.viewChannel));

  // Initializes Guild channel
  void _initialize(Map<String, dynamic> raw, Guild guild) {
    this.name = raw['name'] as String;
    this.position = raw['position'] as int;
    this.guild = guild;

    if (raw['parent_id'] != null) {
      this.parentChannel =
          client.channels[Snowflake(raw['parent_id'])] as CategoryChannel;
    }

    this.nsfw = raw['nsfw'] as bool? ?? false;

    this.permissions = [];
    if (raw['permission_overwrites'] != null) {
      raw['permission_overwrites'].forEach((o) {
        permissions.add(PermissionsOverrides._new(o as Map<String, dynamic>));
      });
    }
  }

  /// Returns effective permissions for [member] to this channel including channel overrides.
  Permissions effectivePermissions(Member member) {
    if (member.guild != this.guild)
      return Permissions.empty();

    if (member.guild.owner == member)
      return Permissions.fromInt(PermissionsConstants.allPermissions);

    var rawMemberPerms = member.effectivePermissions.raw;

    if (PermissionsUtils.isApplied(
        rawMemberPerms, PermissionsConstants.administrator))
      return Permissions.fromInt(PermissionsConstants.allPermissions);

    final overrides = PermissionsUtils.getOverrides(member, this);
    rawMemberPerms =
        PermissionsUtils.apply(rawMemberPerms, overrides.first, overrides.last);

    return PermissionsUtils.isApplied(
            rawMemberPerms, PermissionsConstants.viewChannel)
        ? Permissions.fromInt(rawMemberPerms)
        : Permissions.empty();
  }

  /// Returns effective permissions for [role] to this channel including channel overrides.
  Permissions effectivePermissionForRole(Role role) {
    if (role.guild != this.guild)
      return Permissions.empty();

    var permissions = role.permissions.raw | guild.everyoneRole.permissions.raw;

    /// TODO: NNBD - To consider
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
    params['max_uses'] = maxUses;
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
  Stream<Invite> getChannelInvites() async* {
    final HttpResponse r =
        await client._http.send('GET', "/channels/$id/invites");

    for (Map<String, dynamic> val in (r.body.values.first as Iterable<Map<String, dynamic>>))
      yield Invite._new(val, client);
  }

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermission(
      PermissionsBuilder perms, SnowflakeEntity id,
      {String auditReason = ""}) {
    if (id is! Role || id is! User)
      throw Exception("The `id` property must be either Role or User");

    return client._http.send(
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
