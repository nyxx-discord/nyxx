import 'package:nyxx/src/models/snowflake.dart';

class RoleSubscriptionData {
  final Snowflake listingId;

  final String tierName;

  final int totalMonthsSubscribed;

  final bool isRenewal;

  RoleSubscriptionData({
    required this.listingId,
    required this.tierName,
    required this.totalMonthsSubscribed,
    required this.isRenewal,
  });
}
