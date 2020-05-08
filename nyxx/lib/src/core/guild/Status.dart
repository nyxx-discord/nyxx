part of nyxx;

/// Provides values for user status.
class UserStatus extends IEnum<String> {
  static const UserStatus dnd = const UserStatus._create("dnd");
  static const UserStatus offline = const UserStatus._create("offline");
  static const UserStatus online = const UserStatus._create("online");
  static const UserStatus idle = const UserStatus._create("idle");

  const UserStatus._create(String? value) : super(value ?? "offline");
  UserStatus.from(String? value) : super(value ?? "offline");

  /// Returns if user is online
  bool get isOnline => this != UserStatus.offline;

  @override
  String toString() => _value;

  @override
  bool operator ==(other) {
    if (other is String) {
      return other.toString() == _value;
    }

    return super == other;
  }
}

/// Provides status of user on different devices
class ClientStatus {
  /// The user's status set for an active desktop (Windows, Linux, Mac) application session
  late final UserStatus desktop;

  /// The user's status set for an active mobile (iOS, Android) application session
  late final UserStatus web;

  /// The user's status set for an active web (browser, bot account) application session
  late final UserStatus phone;

  ClientStatus._deserialize(Map<String, dynamic> raw) {
    this.desktop = UserStatus.from(raw['desktop'] as String?);
    this.web = UserStatus.from(raw['web'] as String?);
    this.phone = UserStatus.from(raw['phone'] as String?);
  }

  /// Returns if user is online
  bool get isOnline {
    return this.desktop.isOnline || this.phone.isOnline || this.web.isOnline;
  }

  @override
  int get hashCode {
    return desktop.hashCode * web.hashCode * phone.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is ClientStatus) {
      return other.desktop == this.desktop &&
          other.phone == this.phone &&
          other.web == this.web;
    }

    return false;
  }
}
