import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

abstract class IAuditLogChange {
  /// New value
  dynamic get newValue;

  /// Old value
  dynamic get oldValue;

  /// type of audit log change hey
  ChangeKeyType get key;
}

/// Represents change made in guild with old and new value
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogChange implements IAuditLogChange {
  /// New value
  @override
  dynamic newValue;

  /// Old value
  @override
  dynamic oldValue;

  /// type of audit log change hey
  @override
  late final ChangeKeyType key;

  /// Creates an instance of [AuditLogChange]
  AuditLogChange(RawApiMap raw) {
    if (raw["new_value"] != null) {
      newValue = raw["new_value"];
    }

    if (raw["old_value"] != null) {
      oldValue = raw["old_value"];
    }

    key = ChangeKeyType.from(raw["key"] as String);
  }
}

/// Type of change in audit log
class ChangeKeyType extends IEnum<String> {
  static const ChangeKeyType name = ChangeKeyType._create("name");
  static const ChangeKeyType iconHash = ChangeKeyType._create("icon_hash");
  static const ChangeKeyType splashHash = ChangeKeyType._create("splash_hash");
  static const ChangeKeyType ownerId = ChangeKeyType._create("owner_id");
  static const ChangeKeyType region = ChangeKeyType._create("region");
  static const ChangeKeyType afkChannelId = ChangeKeyType._create("afk_channel_id");
  static const ChangeKeyType afkTimeout = ChangeKeyType._create("afk_timeout");
  static const ChangeKeyType mfaLevel = ChangeKeyType._create("mfa_level");
  static const ChangeKeyType verificationLevel = ChangeKeyType._create("verification_level");
  static const ChangeKeyType explicitContentFilter = ChangeKeyType._create("explicit_content_filter");
  static const ChangeKeyType defaultMessageNotifications = ChangeKeyType._create("default_message_notifications");
  static const ChangeKeyType $add = ChangeKeyType._create("\$add");
  static const ChangeKeyType $remove = ChangeKeyType._create("\$remove");
  static const ChangeKeyType pruneDeleteDays = ChangeKeyType._create("prune_delete_days");
  static const ChangeKeyType widgetEnabled = ChangeKeyType._create("widget_enabled");
  static const ChangeKeyType widgetChannelId = ChangeKeyType._create("widget_channel_id");
  static const ChangeKeyType position = ChangeKeyType._create("position");
  static const ChangeKeyType topic = ChangeKeyType._create("topic");
  static const ChangeKeyType bitrate = ChangeKeyType._create("bitrate");
  static const ChangeKeyType slowmode = ChangeKeyType._create("rate_limit_per_user");
  static const ChangeKeyType permissionOverwrites = ChangeKeyType._create("permission_overwrites");
  static const ChangeKeyType nsfw = ChangeKeyType._create("nsfw");
  static const ChangeKeyType applicationId = ChangeKeyType._create("application_id");
  static const ChangeKeyType permissions = ChangeKeyType._create("permissions");
  static const ChangeKeyType color = ChangeKeyType._create("color");
  static const ChangeKeyType hoist = ChangeKeyType._create("hoist");
  static const ChangeKeyType mentionable = ChangeKeyType._create("mentionable");

  static const ChangeKeyType allow = ChangeKeyType._create("allow");
  static const ChangeKeyType deny = ChangeKeyType._create("deny");
  static const ChangeKeyType code = ChangeKeyType._create("code");
  static const ChangeKeyType channelId = ChangeKeyType._create("channel_id");
  static const ChangeKeyType inviterId = ChangeKeyType._create("inviter_id");
  static const ChangeKeyType maxUses = ChangeKeyType._create("max_uses");
  static const ChangeKeyType uses = ChangeKeyType._create("uses");
  static const ChangeKeyType maxAge = ChangeKeyType._create("max_age");
  static const ChangeKeyType temporary = ChangeKeyType._create("temporary");
  static const ChangeKeyType deaf = ChangeKeyType._create("deaf");
  static const ChangeKeyType mute = ChangeKeyType._create("mute");
  static const ChangeKeyType nick = ChangeKeyType._create("nick");

  static const ChangeKeyType avatarHash = ChangeKeyType._create("avatar_hash");
  static const ChangeKeyType id = ChangeKeyType._create("id");
  static const ChangeKeyType type = ChangeKeyType._create("type");

  /// Creates instance of [ChangeKeyType] from [value]
  ChangeKeyType.from(String value) : super(value);
  const ChangeKeyType._create(String value) : super(value);

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      return other == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}
