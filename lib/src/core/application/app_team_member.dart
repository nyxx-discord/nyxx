import 'package:nyxx/src/core/application/app_team_user.dart';
import 'package:nyxx/src/typedefs.dart';

/// Represent membership of user in app team
abstract class IAppTeamMember {
  /// Basic information of user
  IAppTeamUser get user;

  /// State of membership
  int get membershipState;
}

/// Represent membership of user in app team
class AppTeamMember implements IAppTeamMember {
  /// Basic information of user
  @override
  late final IAppTeamUser user;

  /// State of membership
  @override
  late final int membershipState;

  /// Creates and instance of [AppTeamMember]
  AppTeamMember(RawApiMap raw) {
    this.user = AppTeamUser(raw["user"] as RawApiMap);
    this.membershipState = raw["membership_state"] as int;
  }
}
