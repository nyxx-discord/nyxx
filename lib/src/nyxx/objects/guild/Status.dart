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
  String toString() => _value ?? "offline";

  @override
  int get hashCode => (_value ?? "offline").hashCode;

  @override
  bool operator ==(other) {
    if (other is MemberStatus || other is String)
      return other.toString() == (_value ?? "offline");

    return false;
  }
}

/// Provides status of user on different devices
class ClientStatus {
  MemberStatus desktop;
  MemberStatus web;
  MemberStatus phone;

  ClientStatus._new(this.desktop, this.web, this.phone);
}
