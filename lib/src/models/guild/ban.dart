import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template ban}
/// A ban in a [Guild].
/// {@endtemplate}
class Ban with ToStringHelper {
  /// The reason for the ban.
  final String? reason;

  /// The banned user.
  final User user;

  /// {@macro ban}
  Ban({required this.reason, required this.user});
}
