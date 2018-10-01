part of nyxx;

/// Provides values for user status.
class MemberStatus {
  static const MemberStatus dnd = const MemberStatus._create("dnd");
  static const MemberStatus offline = const MemberStatus._create("offline");
  static const MemberStatus online = const MemberStatus._create("online");
  static const MemberStatus idle = const MemberStatus._create("idle");

  final String _value;

  const MemberStatus._create(this._value);
  MemberStatus.from(this._value);

  @override
  String toString() => _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(other) {
    if (other is MemberStatus || other is String)
      return other.toString() == _value;

    return false;
  }
}
