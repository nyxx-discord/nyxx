import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template team}
/// A group of developers.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/topics/teams#data-models-team-object
/// {@endtemplate}
class Team with ToStringHelper {
  /// The manager for this team.
  final ApplicationManager manager;

  /// The hash of this team's icon.
  final String? iconHash;

  /// This team's ID.
  final Snowflake id;

  /// The members of this team.
  final List<TeamMember> members;

  /// The name of this team.
  final String name;

  /// The ID of the owner of this team.
  final Snowflake ownerId;

  /// {@macro team}
  /// @nodoc
  Team({
    required this.manager,
    required this.iconHash,
    required this.id,
    required this.members,
    required this.name,
    required this.ownerId,
  });

  /// The owner of this team.
  PartialUser get owner => manager.client.users[ownerId];

  /// This team's icon.
  CdnAsset? get icon => iconHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..teamIcons(id: id.toString()),
          hash: iconHash!,
        );
}

/// {@template team_member}
/// A member of a [Team].
/// {@endtemplate}
class TeamMember with ToStringHelper {
  /// This team member's membership status.
  final TeamMembershipState membershipState;

  /// The ID of the team this member belongs to.
  final Snowflake teamId;

  /// The user associated with this team member.
  final PartialUser user;

  /// This team member's role.
  final TeamMemberRole role;

  /// {@macro team_member}
  /// @nodoc
  TeamMember({
    required this.membershipState,
    required this.teamId,
    required this.user,
    required this.role,
  });
}

/// The status of a member in a [Team].
final class TeamMembershipState extends EnumLike<int, TeamMembershipState> {
  /// The user has been invited to the team.
  static const invited = TeamMembershipState(1);

  /// The user has accepted the invitation to the team.
  static const accepted = TeamMembershipState(2);

  /// @nodoc
  const TeamMembershipState(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  TeamMembershipState.parse(int value) : this(value);
}

/// The role of a [TeamMember].
final class TeamMemberRole extends EnumLike<String, TeamMemberRole> {
  static const admin = TeamMemberRole('admin');
  static const developer = TeamMemberRole('developer');
  static const readOnly = TeamMemberRole('read_only');

  const TeamMemberRole(super.value);

  TeamMemberRole.parse(String value) : this(value);
}
