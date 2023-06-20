import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template application_role_connection}
/// A role connection an application has attached to a user.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/user#application-role-connection-object
/// {@endtemplate}
class ApplicationRoleConnection with ToStringHelper {
  /// The vanity name of the platform a bot has connected.
  final String? platformName;

  /// The username of the user on the platform a bot has connected.
  final String? platformUsername;

  /// A mapping of [ApplicationRoleConnectionMetadata] keys to their stringified values.
  final Map<String, String> metadata;

  /// {@macro application_role_connection}
  ApplicationRoleConnection({
    required this.platformName,
    required this.platformUsername,
    required this.metadata,
  });
}
