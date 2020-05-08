part of nyxx;

/// Represents change made in guild with old and new value
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogChange {
  /// New value
  dynamic? newValue;

  /// Old value
  dynamic? oldValue;

  /// type of audit log change hey
  late final ChangeKeyType key;

  AuditLogChange._new(Map<String, dynamic> raw) {
    if (raw['new_value'] != null) {
      newValue = raw['new_value'];
    }

    if (raw['old_value'] != null) {
      oldValue = raw['old_value'];
    }

    this.key = ChangeKeyType(raw['key'] as String);
  }
}

class ChangeKeyType extends IEnum<String> {
  static const ChangeKeyType name = ChangeKeyType._of("name");
  static const ChangeKeyType iconHash = ChangeKeyType._of("icon_hash");
  static const ChangeKeyType splashHash = ChangeKeyType._of("splash_hash");
  static const ChangeKeyType ownerId = ChangeKeyType._of("owner_id");
  static const ChangeKeyType region = ChangeKeyType._of("region");
  static const ChangeKeyType afkChannelId = ChangeKeyType._of("afk_channel_id");
  static const ChangeKeyType afkTimeout = ChangeKeyType._of("afk_timeout");
  static const ChangeKeyType mfaLevel = ChangeKeyType._of("mfa_level");
  static const ChangeKeyType verificationLevel =
      ChangeKeyType._of("verification_level");
  static const ChangeKeyType explicitContentFilter =
      ChangeKeyType._of("explicit_content_filter");
  static const ChangeKeyType defaultMessageNotifications =
      ChangeKeyType._of("default_message_notifications");
  static const ChangeKeyType $add = ChangeKeyType._of("\$add");
  static const ChangeKeyType $remove = ChangeKeyType._of("\$remove");
  static const ChangeKeyType pruneDeleteDays =
      ChangeKeyType._of("prune_delete_days");
  static const ChangeKeyType widgetEnabled =
      ChangeKeyType._of("widget_enabled");
  static const ChangeKeyType widgetChannelId =
      ChangeKeyType._of("widget_channel_id");
  static const ChangeKeyType position = ChangeKeyType._of("position");
  static const ChangeKeyType topic = ChangeKeyType._of("topic");
  static const ChangeKeyType bitrate = ChangeKeyType._of("bitrate");
  static const ChangeKeyType slowmode =
      ChangeKeyType._of("rate_limit_per_user");
  static const ChangeKeyType permissionOverwrites =
      ChangeKeyType._of("permission_overwrites");
  static const ChangeKeyType nsfw = ChangeKeyType._of("nsfw");
  static const ChangeKeyType applicationId =
      ChangeKeyType._of("application_id");
  static const ChangeKeyType permissions = ChangeKeyType._of("permissions");
  static const ChangeKeyType color = ChangeKeyType._of("color");
  static const ChangeKeyType hoist = ChangeKeyType._of("hoist");
  static const ChangeKeyType mentionable = ChangeKeyType._of("mentionable");

  static const ChangeKeyType allow = ChangeKeyType._of("allow");
  static const ChangeKeyType deny = ChangeKeyType._of("deny");
  static const ChangeKeyType code = ChangeKeyType._of("code");
  static const ChangeKeyType channelId = ChangeKeyType._of("channel_id");
  static const ChangeKeyType inviterId = ChangeKeyType._of("inviter_id");
  static const ChangeKeyType maxUses = ChangeKeyType._of("max_uses");
  static const ChangeKeyType uses = ChangeKeyType._of("uses");
  static const ChangeKeyType maxAge = ChangeKeyType._of("max_age");
  static const ChangeKeyType temporary = ChangeKeyType._of("temporary");
  static const ChangeKeyType deaf = ChangeKeyType._of("deaf");
  static const ChangeKeyType mute = ChangeKeyType._of("mute");
  static const ChangeKeyType nick = ChangeKeyType._of("nick");

  static const ChangeKeyType avatarHash = ChangeKeyType._of("avatar_hash");
  static const ChangeKeyType id = ChangeKeyType._of("id");
  static const ChangeKeyType type = ChangeKeyType._of("type");

  const ChangeKeyType._of(String value) : super(value);
  ChangeKeyType(String value) : super(value);

  @override
  bool operator ==(other) {
    if (other is String) {
      return other == this._value;
    }

    return super == other;
  }
}
