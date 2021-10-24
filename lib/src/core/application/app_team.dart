import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/application/app_team_member.dart';
import 'package:nyxx/src/internal/constants.dart';
import 'package:nyxx/src/typedefs.dart';

/// Object of team that manages given app
abstract class IAppTeam implements SnowflakeEntity {
  /// Hash of team icon
  String? get iconHash;

  /// Id of Team owner
  Snowflake get ownerId;

  /// List of members of team
  List<IAppTeamMember> get members;

  /// Returns instance of [IAppTeamMember] of team owner
  IAppTeamMember get ownerMember;

  /// Returns url to team icon
  String? get teamIconUrl;
}

/// Object of team that manages given app
class AppTeam extends SnowflakeEntity implements IAppTeam {
  /// Hash of team icon
  @override
  late final String? iconHash;

  /// Id of Team owner
  @override
  late final Snowflake ownerId;

  /// List of members of team
  @override
  late final List<IAppTeamMember> members;

  /// Returns instance of [IAppTeamMember] of team owner
  @override
  IAppTeamMember get ownerMember => members.firstWhere((element) => element.user.id == ownerId);

  /// Returns url to team icon
  @override
  String? get teamIconUrl {
    if (iconHash != null) {
      return "https://cdn.${Constants.cdnHost}/team-icons/${id.toString()}/$iconHash.png";
    }

    return null;
  }

  /// Creates an instance of [AppTeam]
  AppTeam(RawApiMap raw) : super(Snowflake(raw["id"])) {
    iconHash = raw["icon"] as String?;
    ownerId = Snowflake(raw["owner_user_id"]);

    members = [for (final rawMember in raw["members"]) AppTeamMember(rawMember as RawApiMap)];
  }
}
