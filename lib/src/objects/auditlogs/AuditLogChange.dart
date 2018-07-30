part of nyxx;

/// Represents change made in guild with old and new value
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLogChange {
  /// New value
  dynamic newValue;

  /// Old value
  dynamic oldValue;

  /// type of audit log change hey
  String key;

  Map<String, dynamic> raw;

  AuditLogChange._new(this.raw) {
    if (raw['new_value'] != null) newValue = raw['new_value'];

    if (raw['old_value'] != null) oldValue = raw['old_value'];

    key = raw['key'];
  }
}
