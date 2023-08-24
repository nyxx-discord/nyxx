import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/user/application_role_connection.dart';

class ApplicationRoleConnectionUpdateBuilder extends UpdateBuilder<ApplicationRoleConnection> {
  String? platformName;

  String? platformUsername;

  Map<String, String>? metadata;

  ApplicationRoleConnectionUpdateBuilder({this.platformName = sentinelString, this.platformUsername = sentinelString, this.metadata});

  @override
  Map<String, Object?> build() => {
        if (!identical(platformName, sentinelString)) 'platform_name': platformName,
        if (!identical(platformUsername, sentinelString)) 'platform_username': platformUsername,
        if (metadata != null) 'metadata': metadata,
      };
}
