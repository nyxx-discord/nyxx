import 'dart:async';
import 'dart:convert';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/discord_color.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/connection.dart';
import 'package:nyxx/src/models/user/user.dart';

/// A manager for [User]s.
class UserManager extends ReadOnlyManager<User> {
  /// Create a new [UserManager].
  UserManager(super.config, super.client);

  @override
  PartialUser operator [](Snowflake id) => PartialUser(id: id, manager: this);

  @override
  User parse(Map<String, Object?> raw) {
    final hasAccentColor = raw['accentColor'] != null;
    final hasLocale = raw['locale'] != null;
    final hasFlags = raw['flags'] != null;
    final hasPremiumType = raw['premium_type'] != null;
    final hasPublicFlags = raw['public_flags'] != null;

    return User(
      manager: this,
      id: Snowflake.parse(raw['id'] as String),
      username: raw['username'] as String,
      discriminator: raw['discriminator'] as String,
      avatarHash: raw['avatar'] as String?,
      isBot: raw['bot'] as bool? ?? false,
      isSystem: raw['system'] as bool? ?? false,
      hasMfaEnabled: raw['mfa_enabled'] as bool? ?? false,
      bannerHash: raw['banner'] as String?,
      accentColor: hasAccentColor ? DiscordColor(raw['accentColor'] as int) : null,
      locale: hasLocale ? Locale.parse(raw['locale'] as String) : null,
      flags: hasFlags ? UserFlags(raw['flags'] as int) : null,
      nitroType: hasPremiumType ? NitroType.parse(raw['premium_type'] as int) : NitroType.none,
      publicFlags: hasPublicFlags ? UserFlags(raw['public_flags'] as int) : null,
    );
  }

  Connection parseConnection(Map<String, Object?> raw) {
    return Connection(
      id: raw['id'] as String,
      name: raw['name'] as String,
      type: ConnectionType.parse(raw['type'] as String),
      isRevoked: raw['revoked'] as bool?,
      isVerified: raw['verified'] as bool,
      isFriendSyncEnabled: raw['friend_sync'] as bool,
      showActivity: raw['show_activity'] as bool,
      isTwoWayLink: raw['two_way_link'] as bool,
      visibility: ConnectionVisibility.parse(raw['visibility'] as int),
    );
  }

  @override
  Future<User> fetch(Snowflake id) async {
    final route = HttpRoute()..users(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);

    return parse(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch the current user from the API.
  Future<User> fetchCurrentUser() async {
    final route = HttpRoute()..users(id: '@me');
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);

    return parse(response.jsonBody as Map<String, Object?>);
  }

  /// Update the current user.
  Future<User> updateCurrentUser(UpdateBuilder<User> builder) async {
    final route = HttpRoute()..users(id: '@me');
    final request = BasicRequest(
      route,
      method: 'PATCH',
      body: jsonEncode(builder.build()),
    );

    final response = await client.httpHandler.executeSafe(request);
    final user = parse(response.jsonBody as Map<String, Object?>);

    cache[user.id] = user;

    return user;
  }

  /// Fetch the current user's connections
  Future<List<Connection>> fetchCurrentUserConnections() async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..connections();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final rawObjects = response.jsonBody as List;

    return List.generate(
      rawObjects.length,
      (index) => parseConnection(rawObjects[index] as Map<String, Object?>),
    );
  }
}
