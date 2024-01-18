import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
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
enum TeamMembershipState {
  invited._(1),
  accepted._(2);

  /// The value of this [TeamMembershipState].
  final int value;

  const TeamMembershipState._(this.value);

  /// Parse a [TeamMembershipState] from a [value].
  ///
  /// The [value] must be a valid team membership state.
  factory TeamMembershipState.parse(int value) => TeamMembershipState.values.firstWhere(
        (state) => state.value == value,
        orElse: () => throw FormatException('Unknown team membership state', value),
      );

  @override
  String toString() => 'TeamMembershipState($value)';
}

/// The role of a [TeamMember].
enum TeamMemberRole {
  admin._('admin'),
  developer._('developer'),
  readOnly._('read_only');

  /// The value of this [TeamMemberRole].
  final String value;

  const TeamMemberRole._(this.value);

  /// Parse a [TeamMemberRole] from a [String].
  ///
  /// The [value] must be a valid team member role.
  factory TeamMemberRole.parse(String value) => TeamMemberRole.values.firstWhere(
        (role) => role.value == value,
        orElse: () => throw FormatException('Unknown team member role', value),
      );

  @override
  String toString() => 'TeamMemberRole($value)';
}
