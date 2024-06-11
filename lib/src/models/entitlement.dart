import 'package:nyxx/src/http/managers/entitlement_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';

/// A partial [Entitlement].
class PartialEntitlement extends ManagedSnowflakeEntity<Entitlement> {
  @override
  final EntitlementManager manager;

  /// Create a new [PartialEntitlement].
  /// @nodoc
  PartialEntitlement({required this.manager, required super.id});

  /// Marks a entitlement for the user as consumed.
  Future<void> consume() => manager.consume(id);
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
final class EntitlementType extends EnumLike<int> {
  /// Entitlement was purchased by user.
  static const EntitlementType purchase = EntitlementType._(1);

  /// Entitlement was granted by Discord Nitro subscription.
  static const EntitlementType premiumSubscription = EntitlementType._(2);

  /// Entitlement was gifted by developer.
  static const EntitlementType developerGift = EntitlementType._(3);

  /// Entitlement was purchased by a dev in application test mode.
  static const EntitlementType testModePurchase = EntitlementType._(4);

  /// Entitlement was granted when the SKU was free.
  static const EntitlementType freePurchase = EntitlementType._(5);

  /// Entitlement was gifted by another user.
  static const EntitlementType userGift = EntitlementType._(6);

  /// Entitlement was claimed by user for free as a Nitro Subscriber.
  static const EntitlementType premiumPurchase = EntitlementType._(7);

  /// Entitlement was purchased as an app subscription.
  static const EntitlementType applicationSubscription = EntitlementType._(8);

  static const List<EntitlementType> values = [
    purchase,
    premiumSubscription,
    developerGift,
    testModePurchase,
    freePurchase,
    userGift,
    premiumPurchase,
    applicationSubscription,
  ];

  const EntitlementType._(super.value);

  factory EntitlementType.parse(int value) => parseEnum(values, value);
}
