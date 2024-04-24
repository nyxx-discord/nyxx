import 'package:nyxx/src/http/managers/entitlement_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

/// A partial [Entitlement].
class PartialEntitlement extends ManagedSnowflakeEntity<Entitlement> {
  @override
  final EntitlementManager manager;

  /// Create a new [PartialEntitlement].
  /// @nodoc
  PartialEntitlement({required this.manager, required super.id});

  /// Marks a entitlement for the user as consumed.
  Future<void> consume() => manager.consumeEntitlement(id);
}

/// {@template entitlement}
/// Premium access a user or guild has for an application.
/// {@endtemplate}
class Entitlement extends PartialEntitlement {
  /// The ID of the SKU.
  final Snowflake skuId;

  /// The ID of the [User] this [Entitlement] is for.
  final Snowflake? userId;

  /// The ID of the [Guild] this [Entitlement] is for.
  final Snowflake? guildId;

  /// The ID of the [Application] this [Entitlement] is for.
  final Snowflake applicationId;

  /// The type of this entitlement.
  final EntitlementType type;

  /// Whether entitlement was deleted.
  final bool isDeleted;

  /// Whether this entitlement is consumed.
  final bool isConsumed;

  /// The time at which this entitlement becomes valid.
  final DateTime? startsAt;

  /// The time at which this entitlement expires.
  final DateTime? endsAt;

  /// {@macro entitlement}
  /// @nodoc
  Entitlement({
    required super.manager,
    required super.id,
    required this.skuId,
    required this.userId,
    required this.guildId,
    required this.applicationId,
    required this.type,
    required this.isConsumed,
    required this.isDeleted,
    required this.startsAt,
    required this.endsAt,
  });

  /// The user this entitlement is for.
  PartialUser? get user => userId == null ? null : PartialUser(id: userId!, manager: manager.client.users);

  /// The guild this entitlement is for.
  PartialGuild? get guild => guildId == null ? null : PartialGuild(id: guildId!, manager: manager.client.guilds);

  /// The application this entitlement is for.
  PartialApplication get application => PartialApplication(id: applicationId, manager: manager.client.applications);
}

/// The type of an [Entitlement].
enum EntitlementType {
  /// Entitlement was purchased by user.
  purchase._(1),

  /// Entitlement was granted by Discord Nitro subscription.
  premiumSubscription._(2),

  /// Entitlement was gifted by developer.
  developerGift._(3),

  /// Entitlement was purchased by a dev in application test mode.
  testModePurchase._(4),

  /// Entitlement was granted when the SKU was free.
  freePurchase._(5),

  /// Entitlement was gifted by another user.
  userGift._(6),

  /// Entitlement was claimed by user for free as a Nitro Subscriber.
  premiumPurchase._(7),

  /// Entitlement was purchased as an app subscription.
  applicationSubscription._(8);

  final int value;

  const EntitlementType._(this.value);

  factory EntitlementType.parse(int value) => EntitlementType.values.firstWhere(
        (element) => element.value == value,
        orElse: () => throw FormatException('Unknown entitlement type', value),
      );

  @override
  String toString() => 'EntitlementType($value)';
}
