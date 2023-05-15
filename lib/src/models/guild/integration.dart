import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class Integration with ToStringHelper {
  final Snowflake id;

  final String name;

  final String type;

  final bool isEnabled;

  final bool? isSyncing;

  final Snowflake? roleId;

  final bool? enableEmoticons;

  final IntegrationExpireBehavior? expireBehaviour;

  final Duration? expireGracePeriod;

  final User? user;

  final IntegrationAccount account;

  final DateTime? syncedAt;

  final int? subscriberCount;

  final bool? isRevoked;

  final IntegrationApplication? application;

  final List<String>? scopes;

  Integration({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
    required this.isSyncing,
    required this.roleId,
    required this.enableEmoticons,
    required this.expireBehaviour,
    required this.expireGracePeriod,
    required this.user,
    required this.account,
    required this.syncedAt,
    required this.subscriberCount,
    required this.isRevoked,
    required this.application,
    required this.scopes,
  });
}

enum IntegrationExpireBehavior {
  removeRole._(0),
  kick._(1);

  final int value;

  const IntegrationExpireBehavior._(this.value);

  @override
  String toString() => 'IntegrationExpireBehavior($value)';
}

class IntegrationAccount with ToStringHelper {
  final Snowflake id;

  final String name;

  const IntegrationAccount({required this.id, required this.name});
}

class IntegrationApplication with ToStringHelper {
  final Snowflake id;

  final String name;

  final String? iconHash;

  final String description;

  final User? bot;

  IntegrationApplication({
    required this.id,
    required this.name,
    required this.iconHash,
    required this.description,
    required this.bot,
  });
}
