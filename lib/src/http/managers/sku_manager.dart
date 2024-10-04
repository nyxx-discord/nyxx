import 'package:nyxx/src/errors.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/sku.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';
import 'package:nyxx/src/utils/cache_helpers.dart';

class SkuManager extends ReadOnlyManager<Sku> {
  final Snowflake applicationId;

  SkuManager(super.config, super.client, {required this.applicationId}) : super(identifier: '$applicationId.skus');

  @override
  PartialSku operator [](Snowflake id) => PartialSku(manager: this, id: id);

  @override
  Sku parse(Map<String, Object?> raw) {
    return Sku(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      type: SkuType(raw['type'] as int),
      applicationId: Snowflake.parse(raw['application_id']!),
      name: raw['name'] as String,
      slug: raw['slug'] as String,
      flags: SkuFlags(raw['flags'] as int),
    );
  }

  Future<List<Sku>> list() async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..skus();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final skus = parseMany(response.jsonBody as List, parse);

    skus.forEach(client.updateCacheWith);
    return skus;
  }

  @override
  Future<Sku> fetch(Snowflake id) async {
    final skus = await list();

    return skus.firstWhere(
      (sku) => sku.id == id,
      orElse: () => throw SkuNotFoundException(applicationId, id),
    );
  }
}
