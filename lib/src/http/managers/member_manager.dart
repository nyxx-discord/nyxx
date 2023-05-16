import 'dart:convert';

import 'package:nyxx/src/builders/guild/member.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

class MemberManager extends Manager<Member> {
  final Snowflake guildId;

  MemberManager(super.config, super.client, {required this.guildId});

  @override
  PartialMember operator [](Snowflake id) => PartialMember(id: id, manager: this);

  @override
  Member parse(Map<String, Object?> raw) {
    return Member(
      id: Snowflake.parse(raw['id'] as String),
      manager: this,
      user: maybeParse(raw['user'], client.users.parse),
      nick: raw['nick'] as String?,
      avatarHash: raw['avatar'] as String?,
      roleIds: parseMany(raw['roles'] as List, Snowflake.parse),
      joinedAt: DateTime.parse(raw['joined_at'] as String),
      premiumSince: maybeParse(raw['premium_since'], DateTime.parse),
      isDeaf: raw['deaf'] as bool,
      isMute: raw['mute'] as bool,
      flags: MemberFlags(raw['flags'] as int),
      isPending: raw['pending'] as bool? ?? false,
      permissions: Permissions(int.parse(raw['permissions'] as String)),
      communicationDisabledUntil: maybeParse(raw['communication_disabled_until'], DateTime.parse),
    );
  }

  @override
  Future<Member> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>);

    cache[member.id] = member;
    return member;
  }

  Future<List<Member>> list({int? limit, Snowflake? after}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members();
    final request = BasicRequest(route, queryParameters: {
      if (limit != null) 'limit': limit.toString(),
      if (after != null) 'after': after.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final members = parseMany(response.jsonBody as List, parse);

    cache.addEntries(members.map((e) => MapEntry(e.id, e)));
    return members;
  }

  @override
  Future<Member> create(MemberBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: builder.userId.toString());
    final request = BasicRequest(route, method: 'PUT', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    // TODO: This fails when the member already exists in the guild.
    // The response in that case is a 204 no content, which doesn't throw but has no body.
    final member = parse(response.jsonBody as Map<String, Object?>);

    cache[member.id] = member;
    return member;
  }

  @override
  Future<Member> update(Snowflake id, MemberUpdateBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request = BasicRequest(route, method: 'PATCH', auditLogReason: auditLogReason, body: jsonEncode(builder.build));

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>);

    cache[member.id] = member;
    return member;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  Future<Member> updateCurrentMember(CurrentMemberUpdateBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: '@me');
    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>);

    cache[member.id] = member;
    return member;
  }

  Future<void> addRole(Snowflake id, Snowflake roleId, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString())
      ..roles(id: roleId.toString());
    final request = BasicRequest(route, method: 'PUT', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  Future<void> removeRole(Snowflake id, Snowflake roleId, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString())
      ..roles(id: roleId.toString());
    final request = BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }
}
