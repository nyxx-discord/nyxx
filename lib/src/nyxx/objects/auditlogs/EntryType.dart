part of nyxx;

class AuditLogEntryType {
  static const AuditLogEntryType guildUpdate = AuditLogEntryType._of(1);
  static const AuditLogEntryType channelCreate = AuditLogEntryType._of(10);
  static const AuditLogEntryType channelUpdate = AuditLogEntryType._of(11);
  static const AuditLogEntryType channelDelete = AuditLogEntryType._of(12);
  static const AuditLogEntryType channelOverwriteCreate = AuditLogEntryType._of(13);
  static const AuditLogEntryType channelOverwriteUpdate = AuditLogEntryType._of(14);
  static const AuditLogEntryType channelOverwriteDelete = AuditLogEntryType._of(15);
  static const AuditLogEntryType memberKick = AuditLogEntryType._of(20);
  static const AuditLogEntryType memberPrune = AuditLogEntryType._of(21);
  static const AuditLogEntryType memberBanAdd = AuditLogEntryType._of(22);
  static const AuditLogEntryType memberBanRemove = AuditLogEntryType._of(23);
  static const AuditLogEntryType memberUpdate = AuditLogEntryType._of(24);
  static const AuditLogEntryType memberRoleUpdate = AuditLogEntryType._of(25);
  static const AuditLogEntryType roleCreate = AuditLogEntryType._of(30);
  static const AuditLogEntryType roleUpdate = AuditLogEntryType._of(31);
  static const AuditLogEntryType roleDelete = AuditLogEntryType._of(32);
  static const AuditLogEntryType inviteCreate = AuditLogEntryType._of(40);
  static const AuditLogEntryType inviteUpdate = AuditLogEntryType._of(41);
  static const AuditLogEntryType inviteDelete = AuditLogEntryType._of(42);
  static const AuditLogEntryType webhookCreate = AuditLogEntryType._of(50);
  static const AuditLogEntryType webhookUpdate = AuditLogEntryType._of(51);
  static const AuditLogEntryType webhookDelete = AuditLogEntryType._of(52);
  static const AuditLogEntryType emojiCreate = AuditLogEntryType._of(60);
  static const AuditLogEntryType emojiUpdate = AuditLogEntryType._of(61);
  static const AuditLogEntryType emojiDelete = AuditLogEntryType._of(62);
  static const AuditLogEntryType messageDelete = AuditLogEntryType._of(72);

  final int _value;
  int get value => _value;

  const AuditLogEntryType._of(this._value);
  AuditLogEntryType(this._value);

  @override
  String toString() => _value.toString();

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) =>
      (other is AuditLogEntryType && other.value == this._value) ||
      (other is int && other == this._value);
}