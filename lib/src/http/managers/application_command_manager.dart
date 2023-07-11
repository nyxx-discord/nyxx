import 'dart:convert';

import 'package:nyxx/src/builders/application_command.dart';
import 'package:nyxx/src/http/managers/manager.dart';
import 'package:nyxx/src/http/request.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/commands/application_command.dart';
import 'package:nyxx/src/models/commands/application_command_option.dart';
import 'package:nyxx/src/models/commands/application_command_permissions.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/parsing_helpers.dart';

abstract class ApplicationCommandManager extends Manager<ApplicationCommand> {
  Snowflake? get _guildId;

  final Snowflake applicationId;

  ApplicationCommandManager(super.config, super.client, {required this.applicationId, required super.identifier});

  @override
  PartialApplicationCommand operator [](Snowflake id) => PartialApplicationCommand(id: id, manager: this);

  @override
  ApplicationCommand parse(Map<String, Object?> raw) {
    return ApplicationCommand(
      id: Snowflake.parse(raw['id']!),
      manager: this,
      type: ApplicationCommandType.parse(raw['type'] as int? ?? 1),
      applicationId: Snowflake.parse(raw['application_id']!),
      guildId: maybeParse(raw['guild_id'], Snowflake.parse),
      name: raw['name'] as String,
      nameLocalizations: maybeParse(
        raw['name_localizations'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(Locale.parse(key), value as String),
        ),
      ),
      description: raw['description'] as String,
      descriptionLocalizations: maybeParse(
        raw['description_localizations'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(Locale.parse(key), value as String),
        ),
      ),
      options: maybeParseMany(raw['options'], parseApplicationCommandOption),
      defaultMemberPermissions: maybeParse(raw['default_member_permissions'], (String raw) => Permissions(int.parse(raw))),
      hasDmPermission: raw['dm_permission'] as bool?,
      isNsfw: raw['nsfw'] as bool?,
      version: Snowflake.parse(raw['version']!),
    );
  }

  CommandOption parseApplicationCommandOption(Map<String, Object?> raw) {
    return CommandOption(
      type: CommandOptionType.parse(raw['type'] as int),
      name: raw['name'] as String,
      nameLocalizations: maybeParse(
        raw['name_localizations'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(Locale.parse(key), value as String),
        ),
      ),
      description: raw['description'] as String,
      descriptionLocalizations: maybeParse(
        raw['description_localizations'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(Locale.parse(key), value as String),
        ),
      ),
      isRequired: raw['required'] as bool?,
      choices: maybeParseMany(raw['choices'], parseOptionChoice),
      options: maybeParseMany(raw['options'], parseApplicationCommandOption),
      channelTypes: maybeParseMany(raw['channel_types'], ChannelType.parse),
      minValue: raw['min_value'] as num?,
      maxValue: raw['max_value'] as num?,
      minLength: raw['min_length'] as int?,
      maxLength: raw['max_length'] as int?,
      hasAutocomplete: raw['autocomplete'] as bool?,
    );
  }

  CommandOptionChoice parseOptionChoice(Map<String, Object?> raw) {
    return CommandOptionChoice(
      name: raw['name'] as String,
      nameLocalizations: maybeParse(
        raw['name_localizations'],
        (Map<String, Object?> raw) => raw.map(
          (key, value) => MapEntry(Locale.parse(key), value as String),
        ),
      ),
      value: raw['value'],
    );
  }

  Future<List<ApplicationCommand>> list({bool? withLocalizations}) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands();

    final request = BasicRequest(route, queryParameters: {if (withLocalizations != null) 'with_localizations': withLocalizations.toString()});

    final response = await client.httpHandler.executeSafe(request);
    final commands = parseMany(response.jsonBody as List, parse);

    cache.addEntries(commands.map((command) => MapEntry(command.id, command)));
    return commands;
  }

  @override
  Future<ApplicationCommand> fetch(Snowflake id) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands(id: id.toString());

    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final command = parse(response.jsonBody as Map<String, Object?>);

    cache[command.id] = command;
    return command;
  }

  @override
  Future<ApplicationCommand> create(ApplicationCommandBuilder builder) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands();

    final request = BasicRequest(route, method: 'POST', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final command = parse(response.jsonBody as Map<String, Object?>);

    cache[command.id] = command;
    return command;
  }

  @override
  Future<ApplicationCommand> update(Snowflake id, ApplicationCommandUpdateBuilder builder) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands(id: id.toString());

    final request = BasicRequest(route, method: 'PATCH', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final command = parse(response.jsonBody as Map<String, Object?>);

    cache[command.id] = command;
    return command;
  }

  @override
  Future<void> delete(Snowflake id) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands(id: id.toString());

    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  Future<List<ApplicationCommand>> bulkOverride(List<ApplicationCommandBuilder> builders) async {
    final route = HttpRoute()..applications(id: applicationId.toString());
    if (_guildId != null) route.guilds(id: _guildId!.toString());
    route.commands();

    final request = BasicRequest(route, method: 'PUT', body: jsonEncode([for (final builder in builders) builder.build()]));

    final response = await client.httpHandler.executeSafe(request);
    final commands = parseMany(response.jsonBody as List, parse);

    cache
      ..clear()
      ..addEntries(commands.map((command) => MapEntry(command.id, command)));
    return commands;
  }
}

class GuildApplicationCommandManager extends ApplicationCommandManager {
  final Snowflake guildId;

  @override
  Snowflake get _guildId => guildId;

  GuildApplicationCommandManager(super.config, super.client, {required super.applicationId, required this.guildId}) : super(identifier: '$guildId.commands');

  CommandPermissions parseCommandPermissions(Map<String, Object?> raw) {
    return CommandPermissions(
      id: Snowflake.parse(raw['id']!),
      applicationId: Snowflake.parse(raw['application_id']!),
      guildId: Snowflake.parse(raw['guild_id']!),
      permissions: parseMany(raw['permissions'] as List, parseCommandPermission),
    );
  }

  CommandPermission parseCommandPermission(Map<String, Object?> raw) {
    return CommandPermission(
      id: Snowflake.parse(raw['id']!),
      type: CommandPermissionType.parse(raw['type'] as int),
      hasPermission: raw['permission'] as bool,
    );
  }

  Future<List<CommandPermissions>> listCommandPermissions() async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..guilds(id: guildId.toString())
      ..commands()
      ..permissions();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, parseCommandPermissions);
  }

  Future<List<CommandPermissions>> fetchCommandPermissions(Snowflake id) async {
    final route = HttpRoute()
      ..applications(id: applicationId.toString())
      ..guilds(id: guildId.toString())
      ..commands(id: id.toString())
      ..permissions();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, parseCommandPermissions);
  }

  // TODO: Do we add the command permission endpoints?
}

class GlobalApplicationCommandManager extends ApplicationCommandManager {
  @override
  Null get _guildId => null;

  GlobalApplicationCommandManager(super.config, super.client, {required super.applicationId}) : super(identifier: 'commands');
}
