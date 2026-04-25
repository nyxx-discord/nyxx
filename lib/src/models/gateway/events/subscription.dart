import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/subscription.dart';

/// Sent when a [Subscription] is created.
///
/// {@category events}
class SubscriptionCreateEvent extends DispatchEvent {
  /// The subscription that was created.
  final Subscription subscription;

  /// @nodoc
  SubscriptionCreateEvent({required super.gateway, required this.subscription});
}

/// Sent when a [Subscription] is updated.
///
/// {@category events}
class SubscriptionUpdateEvent extends DispatchEvent {
  /// The subscription before it was updated, if it was cached.
  final Subscription? oldSubscription;

  /// The new subscription.
  final Subscription subscription;

  /// @nodoc
  SubscriptionUpdateEvent({required super.gateway, required this.oldSubscription, required this.subscription});
}

/// Sent when a [Subscription] is deleted.
///
/// {@category events}
class SubscriptionDeleteEvent extends DispatchEvent {
  /// The subscription that was deleted.
  final Subscription subscription;

  /// @nodoc
  SubscriptionDeleteEvent({required super.gateway, required this.subscription});
}
