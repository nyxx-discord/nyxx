import 'package:nyxx/src/models/snowflake.dart';

/// {@template role_subscription_data}
/// Information about a role subscription.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#role-subscription-data-object
/// {@endtemplate}
class RoleSubscriptionData {
  ///The ID of the sku and listing that the user is subscribed to.
  final Snowflake listingId;

  /// The name of the tier that the user is subscribed to.
  final String tierName;

  /// The cumulative number of months that the user has been subscribed for.
  final int totalMonthsSubscribed;

  /// Whether this notification is for a renewal rather than a new purchase.
  final bool isRenewal;

  /// {@macro role_subscription_data}
  /// @nodoc
  RoleSubscriptionData({
    required this.listingId,
    required this.tierName,
    required this.totalMonthsSubscribed,
    required this.isRenewal,
  });
}
