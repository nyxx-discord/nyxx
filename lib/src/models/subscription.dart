import 'package:nyxx/src/http/managers/subscription_manager.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/sku.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/enum_like.dart';

/// A partial [Subscription].
class PartialSubscription extends ManagedSnowflakeEntity<Subscription> {
  @override
  final SubscriptionManager manager;

  /// @nodoc
  PartialSubscription({required this.manager, required super.id});
}

/// A subscription to an [Sku].
class Subscription extends PartialSubscription {
  /// The ID of the user this subscription is for.
  final Snowflake userId;

  /// The IDs of the SKUs this subscription is for.
  final List<Snowflake> skuIds;

  /// The IDs of the entitlements this subscription grants.
  final List<Snowflake> entitlementIds;

  /// The start of the current subscription period.
  final DateTime currentPeriodStart;

  /// The end of the current subscription period.
  final DateTime currentPeriodEnd;

  /// The status of this subscription.
  final SubscriptionStatus status;

  /// If this subscription was canceled, the time at which it was canceled.
  ///
  /// Otherwise, this field will be `null`.
  final DateTime? canceledAt;

  /// The ISO3166-1 alpha-2 country code of the payment source used to purchase this subscription.
  final String? countryCode;

  /// @nodoc
  Subscription({
    required super.manager,
    required super.id,
    required this.userId,
    required this.skuIds,
    required this.entitlementIds,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.status,
    required this.canceledAt,
    required this.countryCode,
  });

  /// The user this subscription is for.
  PartialUser get user => manager.client.users[userId];

  /// The SKUs this subscription is for.
  List<PartialSku> get skus => [
        for (final skuId in skuIds) manager.client.applications[manager.applicationId].skus[skuId],
      ];

  /// The entitlements this subscription grants.
  List<PartialEntitlement> get entitlements => [
        for (final entitlementId in entitlementIds) manager.client.applications[manager.applicationId].entitlements[entitlementId],
      ];
}

/// The status of a [Subscription].
final class SubscriptionStatus extends EnumLike<int, SubscriptionStatus> {
  static const active = SubscriptionStatus(0);
  static const ending = SubscriptionStatus(1);
  static const inactive = SubscriptionStatus(2);

  const SubscriptionStatus(super.value);
}
