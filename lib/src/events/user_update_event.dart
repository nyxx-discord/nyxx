import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IUserUpdateEvent {
  /// User instance after update
  IUser get user;
}

/// Emitted when user was updated
class UserUpdateEvent implements IUserUpdateEvent {
  /// User instance after update
  @override
  late final User user;

  /// Creates na instance of [UserUpdateEvent]
  UserUpdateEvent(RawApiMap json, INyxx client) {
    user = User(client, json["d"] as RawApiMap);
  }
}
