import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A role connection an application has attached to a user.
class ApplicationRoleConnection with ToStringHelper {
  /// The vanity name of the platform a bot has connected.
  final String? platformName;

  /// The username of the user on the platform a bot has connected.
  final String? platformUsername;

  // TODO
  // final Map<String, Object?> metadata;

  ApplicationRoleConnection({
    required this.platformName,
    required this.platformUsername,
    // required this.metadata,
  });
}
