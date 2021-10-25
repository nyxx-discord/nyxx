import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IBan {
  /// Reason of ban
  String? get reason;

  /// Banned user
  IUser get user;
}

/// Ban object. Has attached reason of ban and user who was banned.
class Ban implements IBan {
  /// Reason of ban
  @override
  late final String? reason;

  /// Banned user
  @override
  late final IUser user;

  /// Creates an instance of [Ban]
  Ban(RawApiMap raw, INyxx client) {
    this.reason = raw["reason"] as String;
    this.user = User(client, raw["user"] as RawApiMap);
  }
}
