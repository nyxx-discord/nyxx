import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IInvite {
  /// The invite's code.
  String get code;

  /// A mini guild object for the invite's guild.
  Cacheable<Snowflake, IGuild>? get guild;

  /// A mini channel object for the invite's channel.
  Cacheable<Snowflake, ITextChannel>? get channel;

  /// User who created this invite
  IUser? get inviter;

  /// The target user for this invite
  Cacheable<Snowflake, IUser>? get targetUser;

  /// Reference to bot instance
  INyxx get client;

  /// Returns url to invite
  String get url;

  /// Deletes this [Invite].
  Future<void> delete({String? auditReason});
}

/// Represents invite to guild.
class Invite implements IInvite {
  /// The invite's code.
  @override
  late final String code;

  /// A mini guild object for the invite's guild.
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// A mini channel object for the invite's channel.
  @override
  late final Cacheable<Snowflake, ITextChannel>? channel;

  /// User who created this invite
  @override
  late final IUser? inviter;

  /// The target user for this invite
  @override
  late final Cacheable<Snowflake, IUser>? targetUser;

  /// Reference to bot instance
  @override
  final INyxx client;

  /// Returns url to invite
  @override
  String get url => "https://discord.gg/$code";

  /// Creates an instance of [Invite]
  Invite(RawApiMap raw, this.client) {
    code = raw["code"] as String;

    if (raw["guild"] != null) {
      guild = GuildCacheable(client, Snowflake(raw["guild"]["id"]));
    } else {
      guild = null;
    }

    if (raw["channel"] != null) {
      channel = ChannelCacheable(client, Snowflake(raw["channel"]["id"]));
    } else {
      channel = null;
    }

    if (raw["inviter"] != null) {
      inviter = User(client, raw["inviter"] as RawApiMap);
    } else {
      inviter = null;
    }

    if (raw["target_user"] != null) {
      targetUser = UserCacheable(client, Snowflake(raw["target_user"]["id"]));
    } else {
      targetUser = null;
    }
  }

  /// Deletes this [Invite].
  @override
  Future<void> delete({String? auditReason}) async => client.httpEndpoints.deleteInvite(code, auditReason: auditReason);
}

abstract class IInviteWithMeta implements IInvite {
  /// Date when invite was created
  DateTime get createdAt;

  /// Whether this invite only grants temporary membership
  bool get temporary;

  /// Number of uses of this invite
  int get uses;

  /// Max number of uses of this invite
  int get maxUses;

  /// Duration (in seconds) after which the invite expires
  int get maxAge;

  /// Date when invite will expire
  DateTime get expiryDate;

  /// True if Invite is valid and can be used
  bool get isValid;
}

/// Invite object with additional metadata
class InviteWithMeta extends Invite implements IInviteWithMeta {
  /// Date when invite was created
  @override
  late final DateTime createdAt;

  /// Whether this invite only grants temporary membership
  @override
  late final bool temporary;

  /// Number of uses of this invite
  @override
  late final int uses;

  /// Max number of uses of this invite
  @override
  late final int maxUses;

  /// Duration (in seconds) after which the invite expires
  @override
  late final int maxAge;

  /// Date when invite will expire
  @override
  DateTime get expiryDate => createdAt.add(Duration(seconds: maxAge));

  /// True if Invite is valid and can be used
  @override
  bool get isValid {
    var ageValidity = true;
    var expiryValidity = true;

    if (maxUses > 0) {
      ageValidity = uses <= maxUses;
    }

    if (maxAge > 0) {
      expiryValidity = expiryDate.isAfter(DateTime.now());
    }

    return ageValidity && expiryValidity;
  }

  /// Creates an instance of [InviteWithMeta]
  InviteWithMeta(RawApiMap raw, INyxx client) : super(raw, client) {
    createdAt = DateTime.parse(raw["created_at"] as String);
    temporary = raw["temporary"] as bool;
    uses = raw["uses"] as int;
    maxUses = raw["max_uses"] as int;
    maxAge = raw["max_age"] as int;
  }
}
