import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/channel/invite.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/permissions/permission_overrides.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/permissions/permissions_constants.dart';
import 'package:nyxx/src/core/user/member.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/permissions.dart';

abstract class IGuildChannel implements MinimalGuildChannel {
  /// Relative position of channel in context of channel list
  int get position;

  /// Permission override for channel
  List<IPermissionsOverrides> get permissionOverrides;

  /// Edits channel
  Future<T> edit<T extends GuildChannel>(ChannelBuilder builder, {String? auditReason});

  /// Returns effective permissions for [member] to this channel including channel overrides.
  Future<IPermissions> effectivePermissions(IMember member);

  /// Returns effective permissions for [role] to this channel including channel overrides.
  Future<IPermissions> effectivePermissionForRole(IRole role);

  /// Fetches and returns all channel"s [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  Stream<IInviteWithMeta> fetchChannelInvites();

  /// Allows to set or edit permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  Future<void> editChannelPermissions(PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason});

  /// Allows to edit or set channel permission overrides.
  Future<void> editChannelPermissionOverrides(PermissionOverrideBuilder permissionBuilder, {String? auditReason});

  /// Deletes permission overwrite for given User or Role [entity]
  /// Throws if [entity] isn't [User] or [Role]
  Future<void> deleteChannelPermission(SnowflakeEntity entity, {String? auditReason});

  /// Creates new [IInvite] for [IChannel] and returns it"s instance
  ///
  /// ```
  /// var invite = await channel.createInvite(maxUses: 2137);
  /// ```
  Future<IInvite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason});
}

/// Represents channel within [Guild]. Shares logic for both [TextGuildChannel] and [VoiceGuildChannel].
abstract class GuildChannel extends MinimalGuildChannel implements IGuildChannel {
  /// Relative position of channel in context of channel list
  @override
  late final int position;

  /// Permission override for channel
  @override
  late final List<IPermissionsOverrides> permissionOverrides;

  /// Creates an instance of [GuildChannel]
  GuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    this.position = raw["position"] as int;

    this.permissionOverrides = [
      if (raw["permission_overwrites"] != null)
        for (var obj in raw["permission_overwrites"]) PermissionsOverrides(obj as RawApiMap)
    ];
  }

  /// Edits channel
  @override
  Future<T> edit<T extends GuildChannel>(ChannelBuilder builder, {String? auditReason}) =>
      this.client.httpEndpoints.editGuildChannel(this.id, builder, auditReason: auditReason);

  /// Returns effective permissions for [member] to this channel including channel overrides.
  @override
  Future<IPermissions> effectivePermissions(IMember member) async {
    if (member.guild != this.guild) {
      return Permissions.empty();
    }

    final owner = await member.guild.getOrDownload();
    if (owner == member) {
      return Permissions(PermissionsConstants.allPermissions);
    }

    var rawMemberPerms = (await member.effectivePermissions).raw;

    if (PermissionsUtils.isApplied(rawMemberPerms, PermissionsConstants.administrator)) {
      return Permissions(PermissionsConstants.allPermissions);
    }

    final overrides = PermissionsUtils.getOverrides(member, this);
    rawMemberPerms = PermissionsUtils.apply(rawMemberPerms, overrides.first, overrides.last);

    return PermissionsUtils.isApplied(rawMemberPerms, PermissionsConstants.viewChannel) ? Permissions(rawMemberPerms) : Permissions.empty();
  }

  /// Returns effective permissions for [role] to this channel including channel overrides.
  @override
  Future<IPermissions> effectivePermissionForRole(IRole role) async {
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

    return Permissions(permissions);
  }

  /// Fetches and returns all channel"s [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  @override
  Stream<IInviteWithMeta> fetchChannelInvites() => client.httpEndpoints.fetchChannelInvites(this.id);

  /// Allows to set or edit permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  @override
  Future<void> editChannelPermissions(PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) =>
      client.httpEndpoints.editChannelPermissions(this.id, perms, entity, auditReason: auditReason);

  /// Allows to edit or set channel permission overrides.
  @override
  Future<void> editChannelPermissionOverrides(PermissionOverrideBuilder permissionBuilder, {String? auditReason}) =>
      client.httpEndpoints.editChannelPermissionOverrides(this.id, permissionBuilder, auditReason: auditReason);

  /// Deletes permission overwrite for given User or Role [entity]
  /// Throws if [entity] isn't [User] or [Role]
  @override
  Future<void> deleteChannelPermission(SnowflakeEntity entity, {String? auditReason}) =>
      client.httpEndpoints.deleteChannelPermission(this.id, entity, auditReason: auditReason);

  /// Creates new [Invite] for [IChannel] and returns it"s instance
  ///
  /// ```
  /// var invite = await channel.createInvite(maxUses: 2137);
  /// ```
  @override
  Future<IInvite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) =>
      client.httpEndpoints.createInvite(this.id, maxAge: maxAge, maxUses: maxUses, temporary: temporary, unique: unique, auditReason: auditReason);
}

abstract class IMinimalGuildChannel implements IChannel {
  /// The channel's name.
  String get name;

  /// Id of [Guild] that the channel is in.
  Cacheable<Snowflake, IGuild> get guild;

  /// Id of parent channel
  Cacheable<Snowflake, GuildChannel>? get parentChannel;

  /// Indicates if channel is nsfw
  bool get isNsfw;
}

abstract class MinimalGuildChannel extends Channel implements IMinimalGuildChannel {
  /// The channel's name.
  @override
  late final String name;

  /// Id of [Guild] that the channel is in.
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Id of parent channel
  @override
  late final Cacheable<Snowflake, GuildChannel>? parentChannel;

  /// Indicates if channel is nsfw
  @override
  late final bool isNsfw;

  /// Creates instance of [MinimalGuildChannel]
  MinimalGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw) {
    this.name = raw["name"] as String;

    if (raw["guild_id"] != null) {
      this.guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    } else if (guildId != null) {
      this.guild = GuildCacheable(client, guildId);
    } else {
      throw Exception(
          "Cannot initialize instance of GuildChannelNex due missing `guild_id` in json payload and/or missing optional guildId parameter. Report this issue to developer");
    }

    if (raw["parent_id"] != null) {
      this.parentChannel = ChannelCacheable(client, Snowflake(raw["parent_id"]));
    } else {
      this.parentChannel = null;
    }

    this.isNsfw = raw["nsfw"] as bool? ?? false;
  }
}
