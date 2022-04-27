import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/enum.dart';

/// Provides values for user status.
class UserStatus extends IEnum<String> {
  static const UserStatus dnd = UserStatus._create("dnd");
  static const UserStatus offline = UserStatus._create("offline");
  static const UserStatus online = UserStatus._create("online");
  static const UserStatus idle = UserStatus._create("idle");

  /// Creates instance of [UserStatus] from [value].
  UserStatus.from(String? value) : super(value ?? "offline");
  const UserStatus._create(String? value) : super(value ?? "offline");

  /// Returns if user is online
  bool get isOnline => this != UserStatus.offline;

  @override
  String toString() => value;

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      return other.toString() == value;
    }

    return super == other;
  }

  @override
  int get hashCode => value.hashCode;
}

abstract class IClientStatus {
  /// The user's status set for an active desktop (Windows, Linux, Mac) application session
  UserStatus get desktop;

  /// The user's status set for an active mobile (iOS, Android) application session
  UserStatus get web;

  /// The user's status set for an active web (browser, bot account) application session
  UserStatus get phone;

  /// Returns if user is online
  bool get isOnline;
}

/// Provides status of user on different devices
class ClientStatus implements IClientStatus {
  /// The user's status set for an active desktop (Windows, Linux, Mac) application session
  @override
  late final UserStatus desktop;

  /// The user's status set for an active mobile (iOS, Android) application session
  @override
  late final UserStatus web;

  /// The user's status set for an active web (browser, bot account) application session
  @override
  late final UserStatus phone;

  /// Returns if user is online
  @override
  bool get isOnline => desktop.isOnline || phone.isOnline || web.isOnline;

  /// Creates an instance of [ClientStatus]
  ClientStatus(RawApiMap raw) {
    desktop = UserStatus.from(raw["desktop"] as String?);
    web = UserStatus.from(raw["web"] as String?);
    phone = UserStatus.from(raw["phone"] as String?);
  }

  @override
  int get hashCode => desktop.hashCode * web.hashCode * phone.hashCode;

  @override
  bool operator ==(other) {
    if (other is ClientStatus) {
      return other.desktop == desktop && other.phone == phone && other.web == web;
    }

    return false;
  }
}
