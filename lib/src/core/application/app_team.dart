import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/application/app_team_member.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

/// Object of team that manages given app
abstract class IAppTeam implements SnowflakeEntity {
  /// Reference to [INyxx].
  INyxx get client;

  /// Hash of team icon
  String? get iconHash;

  /// Id of Team owner
  Snowflake get ownerId;

  /// List of members of team
  List<IAppTeamMember> get members;

  /// Returns instance of [IAppTeamMember] of team owner
  IAppTeamMember get ownerMember;

  /// The team's name.
  String get name;

  /// Returns URL to team icon with given [format] and [size].
  String? iconUrl({String? format, int? size});
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

  @override
  final INyxx client;

  @override
  late final String name;

  /// Creates an instance of [AppTeam]
  AppTeam(RawApiMap raw, this.client) : super(Snowflake(raw["id"])) {
    iconHash = raw["icon"] as String?;
    ownerId = Snowflake(raw["owner_user_id"]);
    name = raw['name'] as String;

    members = [for (final rawMember in raw["members"]) AppTeamMember(rawMember as RawApiMap, client)];
  }

  /// Returns url to team icon
  @override
  String? iconUrl({String? format, int? size}) {
    if (iconHash == null) {
      return null;
    }

    return client.cdnHttpEndpoints.teamIcon(id, iconHash!, format: format, size: size);
  }
}
