import 'dart:convert';

import 'package:nyxx/src/builders/entitlement.dart';
import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/entitlement.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

/// A [Manager] for [Entitlement]s.
class EntitlementManager extends ReadOnlyManager<Entitlement> {
  /// The ID of the application this manager is for.
  final Snowflake applicationId;

  /// Create a new [EntitlementManager].
  EntitlementManager(super.config, super.client, {required this.applicationId}) : super(identifier: '$applicationId.entitlements');

  @override
  PartialEntitlement operator [](Snowflake id) => PartialEntitlement(manager: this, id: id);

  @override
  Entitlement parse(Map<String, Object?> raw) {
    return Entitlement(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      skuId: Snowflake.parse(raw['sku_id']!),
      userId: maybeParse(raw['user_id'], Snowflake.parse),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      applicationId: Snowflake.parse(raw['application_id']!),
      type: EntitlementType.parse(raw['type'] as int),
      isConsumed: raw['consumed'] as bool,
      startsAt: maybeParse(raw['starts_at'], DateTime.parse),
      endsAt: maybeParse(raw['ends_at'], DateTime.parse),
    );
  }

  /// List all the entitlements for this application.
  Future<List<Entitlement>> list({
    Snowflake? userId,
    List<Snowflake>? skuIds,
    Snowflake? before,
    Snowflake? after,
    int? limit,
    Snowflake? guildId,
    bool? excludeEnded,
  }) async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..entitlements();
    final request = BasicRequest(route, queryParameters: {
      if (userId != null) 'user_id': userId.toString(),
      if (skuIds != null) 'sku_ids': skuIds.join(','),
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (guildId != null) 'guild_id': guildId.toString(),
      if (excludeEnded != null) 'exclude_ended': excludeEnded.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final entitlements = parseMany(response.jsonBody as List<Object?>, parse);

    entitlements.forEach(client.updateCacheWith);
    return entitlements;
  }

  @override
  Future<Entitlement> fetch(Snowflake id) async {
    final entitlements = await list(before: Snowflake(id.value + 1));

    return entitlements.firstWhere(
      (entitlement) => entitlement.id == id,
      orElse: () => throw EntitlementNotFoundException(applicationId, id),
    );
  }

  /// Create a test entitlement that never expires.
  Future<Entitlement> createTestEntitlement(TestEntitlementBuilder builder) async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..entitlements();
    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final entitlement = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(entitlement);
    return entitlement;
  }

  /// Delete a test entitlement.
  Future<void> deleteTestEntitlement(Snowflake id) async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..entitlements(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }
}
