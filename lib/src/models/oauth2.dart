import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/user/user.dart';

class OAuth2Information {
  /// The current application.
  final PartialApplication application;

  /// The scopes the user has authorized the application for.
  final List<String> scopes;

  /// When the access token expires.
  final DateTime expiresOn;

  /// The user who has authorized, if the user has authorized with the `identify` scope.
  final User? user;

  /// @nodoc
  OAuth2Information({required this.application, required this.scopes, required this.expiresOn, this.user});
}
