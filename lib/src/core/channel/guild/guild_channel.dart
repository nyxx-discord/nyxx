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
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/permissions.dart';
import 'package:nyxx/src/utils/utils.dart';

abstract class IGuildChannel implements IMinimalGuildChannel {
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

  /// Fetches and returns all channel's [Invite]s
  ///
  /// ```
  /// var invites = await chan.fetchChannelInvites();
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

  /// Creates new [IInvite] for [IChannel] and returns it's instance.
  ///
  /// Requires the `CREATE_INSTANT_INVITE` permission.
  ///
  /// [maxAge] in seconds can be between 0 and 604800 (7 days).
  /// If set to 0, the invite will never expire. The default is 24 hours.
  ///
  /// [maxUses] can be between 0 and 100. If set to 0, the invite will have
  /// unlimited uses. The default is 0 (unlimited).
  ///
  /// [temporary] determines whether this invite only grants temporary
  /// membership.
  ///
  /// If [unique] is true, Discord won't try to reuse a similar invite and will
  /// instead always generate a new invite in the request.
  ///
  /// ```
  /// var invite = await channel.createInvite(maxUses: 100);
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
    position = raw["position"] as int;

    permissionOverrides = [
      if (raw["permission_overwrites"] != null)
        for (var obj in raw["permission_overwrites"]) PermissionsOverrides(obj as RawApiMap)
    ];
  }

  /// Edits channel
  @override
  Future<T> edit<T extends GuildChannel>(ChannelBuilder builder, {String? auditReason}) =>
      client.httpEndpoints.editGuildChannel(id, builder, auditReason: auditReason);

  /// Returns effective permissions for [member] to this channel including channel overrides.
  @override
  Future<IPermissions> effectivePermissions(IMember member) async {
    if (member.guild != guild) {
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
    if (role.guild != guild) {
      return Permissions.empty();
    }

    final guildInstance = await guild.getOrDownload();
    var permissions = role.permissions.raw | guildInstance.everyoneRole.permissions.raw;

    final overEveryone = permissionOverrides.firstWhereSafe((f) => f.id == guildInstance.everyoneRole.id);
    if (overEveryone != null) {
      permissions &= ~overEveryone.deny;
      permissions |= overEveryone.allow;
    }

    final overRole = permissionOverrides.firstWhereSafe((f) => f.id == role.id);
    if (overRole != null) {
      permissions &= ~overRole.deny;
      permissions |= overRole.allow;
    }

    return Permissions(permissions);
  }

  /// Fetches and returns all channel's [Invite]s
  ///
  /// ```
  /// var invites = await chan.getChannelInvites();
  /// ```
  @override
  Stream<IInviteWithMeta> fetchChannelInvites() => client.httpEndpoints.fetchChannelInvites(id);

  /// Allows to set or edit permissions for channel. [id] can be either User or Role
  /// Throws if [id] isn't [User] or [Role]
  @override
  Future<void> editChannelPermissions(PermissionsBuilder perms, SnowflakeEntity entity, {String? auditReason}) =>
      client.httpEndpoints.editChannelPermissions(id, perms, entity, auditReason: auditReason);

  /// Allows to edit or set channel permission overrides.
  @override
  Future<void> editChannelPermissionOverrides(PermissionOverrideBuilder permissionBuilder, {String? auditReason}) =>
      client.httpEndpoints.editChannelPermissionOverrides(id, permissionBuilder, auditReason: auditReason);

  /// Deletes permission overwrite for given User or Role [entity]
  /// Throws if [entity] isn't [User] or [Role]
  @override
  Future<void> deleteChannelPermission(SnowflakeEntity entity, {String? auditReason}) =>
      client.httpEndpoints.deleteChannelPermission(id, entity, auditReason: auditReason);

  /// Creates new [Invite] for [IChannel] and returns it's instance.
  ///
  /// Requires the `CREATE_INSTANT_INVITE` permission.
  ///
  /// [maxAge] in seconds can be between 0 and 604800 (7 days).
  /// If set to 0, the invite will never expire. The default is 24 hours.
  ///
  /// [maxUses] can be between 0 and 100. If set to 0, the invite will have
  /// unlimited uses. The default is 0 (unlimited).
  ///
  /// [temporary] determines whether this invite only grants temporary
  /// membership.
  ///
  /// If [unique] is true, Discord won't try to reuse a similar invite and will
  /// instead always generate a new invite in the request.
  ///
  /// ```
  /// var invite = await channel.createInvite(maxUses: 100);
  /// ```
  @override
  Future<IInvite> createInvite({int? maxAge, int? maxUses, bool? temporary, bool? unique, String? auditReason}) =>
      client.httpEndpoints.createInvite(id, maxAge: maxAge, maxUses: maxUses, temporary: temporary, unique: unique, auditReason: auditReason);
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
    name = raw["name"] as String;

    if (raw["guild_id"] != null) {
      guild = GuildCacheable(client, Snowflake(raw["guild_id"]));
    } else if (guildId != null) {
      guild = GuildCacheable(client, guildId);
    } else {
      throw Exception(
          "Cannot initialize instance of GuildChannel due missing `guild_id` in json payload and/or missing optional guildId parameter. Report this issue to developer");
    }

    if (raw["parent_id"] != null) {
      parentChannel = ChannelCacheable(client, Snowflake(raw["parent_id"]));
    } else {
      parentChannel = null;
    }

    isNsfw = raw["nsfw"] as bool? ?? false;
  }
}
