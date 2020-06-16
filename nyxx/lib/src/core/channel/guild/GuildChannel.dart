part of nyxx;

/// Represents channel which is part of guild.
/// Can be represented by [CachelessGuildChannel] or [CacheGuildChannel]
abstract class IGuildChannel extends Channel {
  /// The channel"s name.
  String get name;

  /// The channel's position in the channel list.
  int get position;

  /// Id of [Guild] that the channel is in.
  Snowflake get guildId;

  /// Id of parent channel
  Snowflake? get parentChannelId;

  /// Indicates if channel is nsfw
  bool get isNsfw;

  /// Returns list of [CacheMember] objects who can see this channel
  List<PermissionsOverrides> get permissionOverrides;

  IGuildChannel._new(Map<String, dynamic> raw, int type, Nyxx client) : super._new(raw, type, client);

  /// Fetches and returns all channel"s [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Stream<InviteWithMeta> getChannelInvites();

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermission(PermissionsBuilder perms, SnowflakeEntity id, {String? auditReason});

  /// Deletes permission overwrite for given User or Role [id]
  /// Throws if [id] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity id, {String? auditReason});

  /// Creates new [Invite] for [Channel] and returns it"s instance
  ///
  /// ```
  /// var inv = await chan.createInvite(maxUses: 2137);
  /// ```
  Future<Invite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason});
}

/// Guild channel which does not have access to cache.
abstract class CachelessGuildChannel extends IGuildChannel {
  /// The channel"s name.
  @override
  late final String name;

  /// The channel's position in the channel list.
  @override
  late final int position;

  /// Id of [Guild] that the channel is in.
  @override
  final Snowflake guildId;

  /// Id of parent channel
  @override
  late final Snowflake? parentChannelId;

  /// Indicates if channel is nsfw
  @override
  late final bool isNsfw;

  /// Returns list of [CacheMember] objects who can see this channel
  @override
  late final List<PermissionsOverrides> permissionOverrides;

  CachelessGuildChannel._new(Map<String, dynamic> raw, int type, this.guildId, Nyxx client) : super._new(raw, type, client) {
    this.name = raw["name"] as String;
    this.position = raw["position"] as int;

    this.parentChannelId = raw["parent_id"] != null ? Snowflake(raw["parent_id"]) : null;
    this.isNsfw = raw["nsfw"] as bool? ?? false;

    this.permissionOverrides = [
      if (raw["permission_overwrites"] != null)
        for (var obj in raw["permission_overwrites"])
          PermissionsOverrides._new(obj as Map<String, dynamic>)
    ];
  }

  /// Fetches and returns all channel"s [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  @override
  Stream<InviteWithMeta> getChannelInvites() async* {
    final response = await client._http._execute(BasicRequest._new("/channels/$id/invites"));

    if (response is HttpResponseError) {
      yield* Stream.error(response);
    }

    final bodyValues = (response as HttpResponseSuccess).jsonBody.values.first;

    for (final val in bodyValues as Iterable<Map<String, dynamic>>) {
      yield InviteWithMeta._new(val, client);
    }
  }

  /// Allows to set permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  @override
  Future<void> editChannelPermission(PermissionsBuilder perms, SnowflakeEntity id, {String? auditReason}) {
    if (id is! Role || id is! User) {
      throw ArgumentError("The `id` property must be either Role or User");
    }

    return client._http._execute(BasicRequest._new("/channels/${this.id}/permissions/${id.toString()}",
        method: "PUT", body: perms._build()._build(), auditLog: auditReason));
  }

  /// Deletes permission overwrite for given User or Role [id]
  /// Throws if [id] isn't [User] or [Role]
  @override
  Future<void> deleteChannelPermission(SnowflakeEntity id, {String? auditReason}) async {
    if (id is! Role || id is! User) {
      throw ArgumentError("`id` property must be either Role or User");
    }

    await client._http
        ._execute(BasicRequest._new("/channels/${this.id}/permissions/$id", method: "PUT", auditLog: auditReason));
  }

  /// Creates new [Invite] for [Channel] and returns it"s instance
  ///
  /// ```
  /// var inv = await chan.createInvite(maxUses: 2137);
  /// ```
  @override
  Future<Invite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) async {
    final body = {
      if (maxAge != null) "max_age": maxAge,
      if (maxAge != null) "max_uses": maxUses,
      if (maxAge != null) "temporary": temporary,
      if (maxAge != null) "unique": unique,
    };

    final response = await client._http
        ._execute(BasicRequest._new("/channels/$id/invites", method: "POST", body: body, auditLog: auditReason));

    if (response is HttpResponseError) {
      return Future.error(response);
    }

    return InviteWithMeta._new((response as HttpResponseSuccess).jsonBody as Map<String, dynamic>, client);
  }
}

/// Guild channel which does have access to cache.
abstract class CacheGuildChannel extends CachelessGuildChannel {
  /// The guild that the channel is in.
  late Guild guild;

  /// Parent channel id
  CategoryChannel? parentChannel;

  /// Returns list of [CacheMember] objects who can see this channel
  Iterable<IMember> get users => this.guild.members.values.where((member) => member is CacheMember && this.effectivePermissions(member).hasPermission(PermissionsConstants.viewChannel));

  CacheGuildChannel._new(Map<String, dynamic> raw, int type, this.guild, Nyxx client) : super._new(raw, type, guild.id, client) {
    if(this.parentChannelId != null) {
      this.parentChannel = guild.channels[this.parentChannelId!] as CategoryChannel?;
    }
  }

  /// Returns effective permissions for [member] to this channel including channel overrides.
  Permissions effectivePermissions(CacheMember member) {
    if (member.guild != this.guild) {
      return Permissions.empty();
    }

    if (member.guild.owner == member) {
      return Permissions.fromInt(PermissionsConstants.allPermissions);
    }

    var rawMemberPerms = member.effectivePermissions.raw;

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
  Permissions effectivePermissionForRole(Role role) {
    if (role.guild != this.guild) {
      return Permissions.empty();
    }

    var permissions = role.permissions.raw | (guild.everyoneRole as Role).permissions.raw;

    // TODO: NNBD: try-catch in where
    try {
      final overEveryone = this.permissionOverrides.firstWhere((f) => f.id == guild.everyoneRole.id);

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
}
