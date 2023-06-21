import 'package:nyxx/src/http/managers/application_manager.dart';
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
  Team({
    required this.manager,
    required this.iconHash,
    required this.id,
    required this.members,
    required this.name,
    required this.ownerId,
  });

  PartialUser get owner => manager.client.users[ownerId];
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

  /// {@macro team_member}
  TeamMember({
    required this.membershipState,
    required this.teamId,
    required this.user,
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
