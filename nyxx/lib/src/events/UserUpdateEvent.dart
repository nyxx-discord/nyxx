import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IUserUpdateEvent {
  /// User instance after update
  IUser get user;
}

// TODO: ???
/// Emitted when user was updated
class UserUpdateEvent implements IUserUpdateEvent {
  /// User instance after update
  @override
  late final User user;

  /// Creates na instance of [UserUpdateEvent]
  UserUpdateEvent(RawApiMap json, INyxx client) {
    this.user = User(client, json["d"] as RawApiMap);
  }
}
