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

    this.permissions = [
      if (raw['permission_overwrites'] != null)
        for(var obj in raw['permission_overwrites'])
          PermissionsOverrides._new(obj as Map<String, dynamic>)
    ];
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

    PermissionsOverrides? overEveryone =
        this.permissions.firstWhere((f) => f.id == guild.everyoneRole.id, orElse: () => null);

    if(overEveryone != null) {
      permissions &= ~overEveryone.deny;
      permissions |= overEveryone.allow;
    }

    PermissionsOverrides? overRole = this.permissions.firstWhere((f) => f.id == role.id, orElse: () => null);

    if(overRole != null) {
      permissions &= ~overRole.deny;
      permissions |= overRole.allow;
    }

    return Permissions.fromInt(permissions);
  }

  /// Creates new [Invite] for [Channel] and returns it's instance
  ///
  /// ```
  /// var inv = await chan.createInvite(maxUses: 2137);
  /// ```
  Future<Invite> createInvite(
      {int? maxAge,
      int? maxUses,
      bool? temporary,
      bool? unique,
      String? auditReason}) async {

    Map<String, dynamic> body = {
      if(maxAge != null) 'max_age' : maxAge,
      if(maxAge != null) 'max_uses' : maxUses,
      if(maxAge != null) 'temporary' : temporary,
      if(maxAge != null) 'unique' : unique,
    };

    var response = await client._http._execute(
        BasicRequest._new("/channels/$id/invites", method: "POST", body: body, auditLog: auditReason));

    if(response is HttpResponseError) {
      return Future.error(response);
    }

    return InviteWithMeta._new((response as HttpResponseSuccess).jsonBody as Map<String, dynamic>, client);
  }

  /// Fetches and returns all channel's [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Stream<InviteWithMeta> getChannelInvites() async* {
    final HttpResponse response =
        await client._http._execute(BasicRequest._new("/channels/$id/invites"));

    if(response is HttpResponseError) {
      yield* Stream.error(response);
    }

    var bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (Map<String, dynamic> val in (bodyValues as Iterable<Map<String, dynamic>>))
      yield InviteWithMeta._new(val, client);
  }

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermission(
      PermissionsBuilder perms, SnowflakeEntity id,
      {String? auditReason}) {
    if (id is! Role || id is! User) {
      throw Exception("The `id` property must be either Role or User");
    }

    return client._http._execute(
        BasicRequest._new("/channels/${this.id}/permissions/${id.toString()}",
            method: "PUT", body: perms._build()._build(), auditLog: auditReason));
  }

  /// Deletes permission overwrite for given User or Role [id]
  /// Throws if [id] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity id,
      {String? auditReason}) async {
    if (id is! Role || id is! User) {
      throw Exception("`id` property must be either Role or User");
    }

    return client._http._execute(BasicRequest._new("/channels/${this.id}/permissions/$id",
        method: "PUT", auditLog: auditReason));
  }
}
