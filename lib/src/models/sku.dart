import 'package:nyxx/src/http/managers/sku_manager.dart';
import 'package:nyxx/src/http/managers/subscription_manager.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';

/// A partial [Sku].
class PartialSku extends ManagedSnowflakeEntity<Sku> {
  @override
  final SkuManager manager;

  /// A manager for this [Sku]'s [Subscription]s.
  SubscriptionManager get subscriptions =>
      SubscriptionManager(manager.client.options.subscriptionConfig, manager.client, applicationId: manager.applicationId, skuId: id);

  /// @nodoc
  PartialSku({required this.manager, required super.id});
}

/// {@template sku}
/// A premium offering that can be made available to your application's users or guilds.
/// {@endtemplate}
class Sku extends PartialSku {
  /// This SKU's type.
  final SkuType type;

  /// The ID of the application this SKU belongs to.
  final Snowflake applicationId;

  /// The name of this SKU.
  final String name;

  /// The URL slug for this SKU.
  final String slug;

  /// This SKU's flags.
  final SkuFlags flags;

  /// {@macro sku}
  /// @nodoc
  Sku({
    required super.manager,
    required super.id,
    required this.type,
    required this.applicationId,
    required this.name,
    required this.slug,
    required this.flags,
  });

  /// The application this SKU belongs to.
  PartialApplication get application => PartialApplication(id: applicationId, manager: manager.client.applications);
}

/// The type of an [Sku].
final class SkuType extends EnumLike<int, SkuType> {
  /// Durable one-time purchase.
  static const durable = SkuType(2);

  /// Consumable one-time purchase.
  static const consumable = SkuType(3);

  /// Subscription.
  static const subscription = SkuType(5);

  /// Subscription group.
  static const subscriptionGroup = SkuType(6);

  /// @nodoc
  const SkuType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  SkuType.parse(int value) : this(value);
}

/// Flags applied to an [Sku].
class SkuFlags extends Flags<SkuFlags> {
  /// The SKU is available for purchase.
  static const available = Flag<SkuFlags>.fromOffset(2);

  /// The SKU is a guild subscription.
  static const guildSubscription = Flag<SkuFlags>.fromOffset(7);

  /// The SKU is a user subscription.
  static const userSubscription = Flag<SkuFlags>.fromOffset(8);

  /// Create a new [SkuFlags].
  SkuFlags(super.value);

  /// Whether this set of flags has the [available] flag set.
  bool get isAvailable => has(available);

  /// Whether this set of flags has the [guildSubscription] flag set.
  bool get isGuildSubscription => has(guildSubscription);

  /// Whether this set of flags has the [userSubscription] flag set.
  bool get isUserSubscription => has(userSubscription);
}
