import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/subscription.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';

class SubscriptionManager extends ReadOnlyManager<Subscription> {
  final Snowflake applicationId;
  final Snowflake skuId;

  SubscriptionManager(super.client, super.config, {required this.applicationId, required this.skuId})
      : super(identifier: '$applicationId.$skuId.subscriptions');

  @override
  PartialSubscription operator [](Snowflake id) => PartialSubscription(manager: this, id: id);

  @override
  Subscription parse(Map<String, Object?> raw) {
    return Subscription(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      userId: Snowflake.parse(raw['user_id']!),
      skuIds: parseMany(raw['sku_ids'] as List, Snowflake.parse),
      entitlementIds: parseMany(raw['entitlement_ids'] as List, Snowflake.parse),
      currentPeriodStart: DateTime.parse(raw['current_period_start'] as String),
      currentPeriodEnd: DateTime.parse(raw['current_period_end'] as String),
      status: SubscriptionStatus(raw['status'] as int),
      canceledAt: maybeParse(raw['canceled_at'], DateTime.parse),
      countryCode: raw['country'] as String?,
    );
  }

  @override
  Future<Subscription> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..skus(id: skuId.toString())
      ..subscriptions(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final subscription = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(subscription);
    return subscription;
  }

  Future<List<Subscription>> list({Snowflake? before, Snowflake? after, int? limit, Snowflake? userId}) async {
    final route = HttpRoute()
      ..skus(id: skuId.toString())
      ..subscriptions();
    final request = BasicRequest(route, queryParameters: {
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (userId != null) 'user_id': userId.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final subscriptions = parseMany(response.jsonBody as List, parse);

    subscriptions.forEach(client.updateCacheWith);
    return subscriptions;
  }
}
