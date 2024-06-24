import 'package:nyxx/src/http/managers/integration_manager.dart';
import 'package:nyxx/src/models/role.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [Integration].
class PartialIntegration extends ManagedSnowflakeEntity<Integration> {
  @override
  final IntegrationManager manager;

  /// Create a new [PartialIntegration].
  /// @nodoc
  PartialIntegration({required super.id, required this.manager});

  /// Delete this integration.
  Future<void> delete({String? auditLogReason}) => manager.delete(id, auditLogReason: auditLogReason);
}

/// {@template integration}
/// An integration in a [Guild].
/// {@endtemplate}
class Integration extends PartialIntegration {
  /// The name of this integration.
  final String name;

  /// The type of this integration.
  final String type;

  /// Whether this integration is enabled.
  final bool isEnabled;

  /// Whether this integration is syncing.
  final bool? isSyncing;

  /// The ID of the role this integration uses for subscribers.
  final Snowflake? roleId;

  /// Whether emoticons should be synced for this integration.
  final bool? enableEmoticons;

  /// The behavior of expiring subscribers for this integration.
  final IntegrationExpireBehavior? expireBehavior;

  /// The grace period for expiring subscribers.
  final Duration? expireGracePeriod;

  /// The user for this integration.
  final User? user;

  /// Information about this integration's account.
  final IntegrationAccount account;

  /// The time at which this integration last synced.
  final DateTime? syncedAt;

  /// The number of subscribers to this integration.
  final int? subscriberCount;

  /// Whether this integration is revoked.
  final bool? isRevoked;

  /// The application for this integration.
  final IntegrationApplication? application;

  /// The OAuth2 scopes this integration is authorized for.
  final List<String>? scopes;

  /// {@macro integration}
  /// @nodoc
  Integration({
    required super.id,
    required super.manager,
    required this.name,
    required this.type,
    required this.isEnabled,
    required this.isSyncing,
    required this.roleId,
    required this.enableEmoticons,
    required this.expireBehavior,
    required this.expireGracePeriod,
    required this.user,
    required this.account,
    required this.syncedAt,
    required this.subscriberCount,
    required this.isRevoked,
    required this.application,
    required this.scopes,
  });

  /// The role this integration uses for subscribers.
  PartialRole? get role => roleId == null ? null : manager.client.guilds[manager.guildId].roles[roleId!];
}

/// The behavior of an integration when a member's subscription expires.
final class IntegrationExpireBehavior extends EnumLike<int, IntegrationExpireBehavior> {
  static const removeRole = IntegrationExpireBehavior(0);
  static const kick = IntegrationExpireBehavior(1);

  /// @nodoc
  const IntegrationExpireBehavior(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  IntegrationExpireBehavior.parse(int value) : this(value);
}

/// {@template integration_account}
/// Information about an integration's account.
/// {@endtemplate}
class IntegrationAccount with ToStringHelper {
  /// The ID of this account.
  final Snowflake id;

  /// The name of this account.
  final String name;

  /// {@macro integration_account}
  /// @nodoc
  IntegrationAccount({required this.id, required this.name});
}

/// {@template integration_application}
/// Information about an integration's application.
/// {@endtemplate}
class IntegrationApplication with ToStringHelper {
  /// The ID of this application.
  final Snowflake id;

  /// The name of this application.
  final String name;

  /// The hash of this application's icon.
  final String? iconHash;

  /// The description of this application.
  final String description;

  /// The bot associated with this application.
  final User? bot;

  /// {@macro integration_application}
  /// @nodoc
  IntegrationApplication({
    required this.id,
    required this.name,
    required this.iconHash,
    required this.description,
    required this.bot,
  });
}
