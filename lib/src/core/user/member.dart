import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/permissions/permissions_constants.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/core/voice/voice_state.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/permissions.dart';

abstract class IMember implements SnowflakeEntity, Mentionable {
  /// Reference to client
  INyxx get client;

  /// [Cacheable] for this [Guild] member
  Cacheable<Snowflake, IUser> get user;

  /// The members nickname, null if not set.
  String? get nickname;

  /// When the member joined the guild.
  DateTime get joinedAt;

  /// Weather or not the member is deafened.
  bool get deaf;

  /// Weather or not the member is muted.
  bool get mute;

  /// Cacheable of guild where member is located
  Cacheable<Snowflake, IGuild> get guild;

  /// Roles of member
  Iterable<Cacheable<Snowflake, IRole>> get roles;

  /// Highest role of member
  Cacheable<Snowflake, IRole> get hoistedRole;

  /// When the user starting boosting the guild
  DateTime? get boostingSince;

  /// Member's avatar in [IGuild]
  String? get avatarHash;

  /// Voice state of member. Null if not connected to channel or voice state not cached
  IVoiceState? get voiceState;

  /// The channel's mention string.
  @override
  String get mention;

  // TODO: is everything okay?
  /// Returns highest role of member.
  /// Uses ! on nullable properties and will throw if anything is missing from cache
  IRole get highestRole;

  /// Returns total permissions of user.
  Future<IPermissions> get effectivePermissions;

  /// Returns url to member avatar
  String? avatarURL({String format = "webp"});

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason});

  /// Adds role to user.
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(SnowflakeEntity role, {String? auditReason});

  /// Removes [role] from user.
  Future<void> removeRole(SnowflakeEntity role, {String? auditReason});

  /// Kicks the member from guild
  Future<void> kick({String? auditReason});

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  Future<void> edit(
      {String? nick = "", List<SnowflakeEntity>? roles, bool? mute, bool? deaf, Snowflake? channel = const Snowflake.zero(), String? auditReason});
}

class Member extends SnowflakeEntity implements IMember {
  /// Reference to client
  @override
  final INyxx client;

  /// [Cacheable] for this [Guild] member
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// The members nickname, null if not set.
  @override
  String? nickname;

  /// When the member joined the guild.
  @override
  late final DateTime joinedAt;

  /// Weather or not the member is deafened.
  @override
  late final bool deaf;

  /// Weather or not the member is muted.
  @override
  late final bool mute;

  /// Cacheable of guild where member is located
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// Roles of member
  @override
  late Iterable<Cacheable<Snowflake, IRole>> roles;

  /// Highest role of member
  @override
  late final Cacheable<Snowflake, IRole> hoistedRole;

  /// When the user starting boosting the guild
  @override
  late DateTime? boostingSince;

  /// Member's avatar in [Guild]
  @override
  late final String? avatarHash;

  /// Voice state of member. Null if not connected to channel or voice state not cached
  @override
  IVoiceState? get voiceState => guild.getFromCache()?.voiceStates[id];

  /// The channel's mention string.
  @override
  String get mention => "<@$id>";

  // TODO: is everything okay?
  /// Returns highest role of member.
  /// Uses ! on nullable properties and will throw if anything is missing from cache
  @override
  IRole get highestRole => roles.reduce((value, element) {
        final valueInstance = value.getFromCache();
        final elementInstance = element.getFromCache();

        if (valueInstance!.position > elementInstance!.position) {
          return value;
        }

        return element;
      }).getFromCache()!;

  /// Returns total permissions of user.
  @override
  Future<IPermissions> get effectivePermissions async {
    final guildInstance = await guild.getOrDownload();
    final owner = await guildInstance.owner.getOrDownload();
    if (this == owner) {
      return Permissions.all();
    }

    var total = guildInstance.everyoneRole.permissions.raw;
    for (final role in roles) {
      final roleInstance = await role.getOrDownload();

      total |= roleInstance.permissions.raw;

      if (PermissionsUtils.isApplied(total, PermissionsConstants.administrator)) {
        return Permissions(PermissionsConstants.allPermissions);
      }
    }

    return Permissions(total);
  }

  /// Creates an instance of [Member]
  Member(this.client, RawApiMap raw, Snowflake guildId) : super(Snowflake(raw["user"]["id"])) {
    nickname = raw["nick"] as String?;
    deaf = raw["deaf"] as bool? ?? false;
    mute = raw["mute"] as bool? ?? false;
    user = UserCacheable(client, id);
    guild = GuildCacheable(client, guildId);
    boostingSince = DateTime.tryParse(raw["premium_since"] as String? ?? "");
    avatarHash = raw["avatar"] as String?;

    roles = [for (var id in raw["roles"]) RoleCacheable(client, Snowflake(id), guild)];

    if (raw["hoisted_role"] != null) {
      hoistedRole = RoleCacheable(client, Snowflake(raw["hoisted_role"]), guild);
    }

    if (raw["joined_at"] != null) {
      joinedAt = DateTime.parse(raw["joined_at"] as String).toUtc();
    }

    if (client.cacheOptions.userCachePolicyLocation.objectConstructor) {
      final userRaw = raw["user"] as RawApiMap;

      if (userRaw["id"] != null && userRaw.length != 1) {
        client.users[id] = User(client, userRaw);
      }
    }
  }

  /// Returns url to member avatar
  @override
  String? avatarURL({String format = "webp"}) {
    if (avatarHash == null) {
      return null;
    }

    return client.httpEndpoints.memberAvatarURL(id, guild.id, avatarHash!, format: format);
  }

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  @override
  Future<void> ban({int? deleteMessageDays, String? reason, String? auditReason}) async =>
      client.httpEndpoints.guildBan(guild.id, id, auditReason: auditReason);

  /// Adds role to user.
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  @override
  Future<void> addRole(SnowflakeEntity role, {String? auditReason}) => client.httpEndpoints.addRoleToUser(guild.id, role.id, id, auditReason: auditReason);

  /// Removes [role] from user.
  @override
  Future<void> removeRole(SnowflakeEntity role, {String? auditReason}) =>
      client.httpEndpoints.removeRoleFromUser(guild.id, role.id, id, auditReason: auditReason);

  /// Kicks the member from guild
  @override
  Future<void> kick({String? auditReason}) => client.httpEndpoints.guildKick(guild.id, id);

  /// Edits members. Allows to move user in voice channel, mute or deaf, change nick, roles.
  @override
  Future<void> edit(
          {String? nick = "", List<SnowflakeEntity>? roles, bool? mute, bool? deaf, Snowflake? channel = const Snowflake.zero(), String? auditReason}) =>
      client.httpEndpoints.editGuildMember(guild.id, id, nick: nick, roles: roles, mute: mute, deaf: deaf, channel: channel, auditReason: auditReason);

  void updateMember(String? nickname, List<Snowflake> roles, DateTime? boostingSince) {
    if (this.nickname != nickname) {
      this.nickname = nickname;
    }

    if (this.roles != roles) {
      this.roles = roles.map((e) => RoleCacheable(client, e, guild));
    }

    if (this.boostingSince == null && boostingSince != null) {
      this.boostingSince = boostingSince;
    }
  }
}
