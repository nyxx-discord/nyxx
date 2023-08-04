import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';

final sampleCommand = {
  "id": "1102343284505968762",
  "application_id": "1033681843708510238",
  "version": "1107729458535878799",
  "default_member_permissions": null,
  "type": 1,
  "name": "ping",
  "name_localizations": null,
  "description": "Ping the bot",
  "description_localizations": null,
  "dm_permission": true,
  "contexts": null,
  "nsfw": false,
};

void checkCommand(ApplicationCommand command) {
  expect(command.id, equals(Snowflake(1102343284505968762)));
  expect(command.type, equals(ApplicationCommandType.chatInput));
  expect(command.applicationId, equals(Snowflake(1033681843708510238)));
  expect(command.guildId, isNull);
  expect(command.name, equals('ping'));
  expect(command.nameLocalizations, isNull);
  expect(command.description, equals('Ping the bot'));
  expect(command.descriptionLocalizations, isNull);
  expect(command.options, isNull);
  expect(command.defaultMemberPermissions, isNull);
  expect(command.hasDmPermission, isTrue);
  expect(command.isNsfw, isFalse);
  expect(command.version, equals(Snowflake(1107729458535878799)));
}

final sampleCommandPermissions = {
  'id': '0',
  'application_id': '1',
  'guild_id': '2',
  'permissions': [
    {
      'id': '3',
      'type': 1,
      'permission': true,
    },
  ],
};

void checkCommandPermissions(CommandPermissions permissions) {
  expect(permissions.id, equals(Snowflake.zero));
  expect(permissions.applicationId, equals(Snowflake(1)));
  expect(permissions.guildId, equals(Snowflake(2)));
  expect(permissions.permissions, hasLength(1));

  final permission = permissions.permissions.single;

  expect(permission.id, equals(Snowflake(3)));
  expect(permission.type, equals(CommandPermissionType.role));
  expect(permission.hasPermission, isTrue);
}

void main() {
  testManager<ApplicationCommand, GlobalApplicationCommandManager>(
    'GlobalApplicationCommandManager',
    (config, client) => GlobalApplicationCommandManager(config, client, applicationId: Snowflake.zero),
    RegExp(r'/applications/0/commands/\d+'),
    '/applications/0/commands',
    sampleObject: sampleCommand,
    sampleMatches: checkCommand,
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<GlobalApplicationCommandManager, List<ApplicationCommand>, List<Object?>>(
        name: 'list',
        source: [sampleCommand],
        urlMatcher: '/applications/0/commands',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkCommand(list.single);
        },
      ),
      EndpointTest<GlobalApplicationCommandManager, List<ApplicationCommand>, List<Object?>>(
        name: 'bulkOverride',
        method: 'PUT',
        source: [sampleCommand],
        urlMatcher: '/applications/0/commands',
        execute: (manager) => manager.bulkOverride([ApplicationCommandBuilder(name: 'TEST', type: ApplicationCommandType.chatInput)]),
        check: (list) {
          expect(list, hasLength(1));
          checkCommand(list.single);
        },
      ),
    ],
    createBuilder: ApplicationCommandBuilder(name: 'TEST', type: ApplicationCommandType.chatInput),
    updateBuilder: ApplicationCommandUpdateBuilder(),
  );

  testManager<ApplicationCommand, GuildApplicationCommandManager>(
    'GuildApplicationCommandManager',
    (config, client) => GuildApplicationCommandManager(
      config,
      client,
      applicationId: Snowflake.zero,
      guildId: Snowflake(1),
      permissionsConfig: const CacheConfig(),
    ),
    RegExp(r'/applications/0/guilds/1/commands/\d+'),
    '/applications/0/guilds/1/commands',
    sampleObject: sampleCommand,
    sampleMatches: checkCommand,
    additionalParsingTests: [
      ParsingTest<GuildApplicationCommandManager, CommandPermissions, Map<String, Object?>>(
        name: 'parseCommandPermissions',
        source: sampleCommandPermissions,
        parse: (manager) => manager.parseCommandPermissions,
        check: checkCommandPermissions,
      ),
    ],
    additionalEndpointTests: [
      EndpointTest<GuildApplicationCommandManager, List<ApplicationCommand>, List<Object?>>(
        name: 'list',
        source: [sampleCommand],
        urlMatcher: '/applications/0/guilds/1/commands',
        execute: (manager) => manager.list(),
        check: (list) {
          expect(list, hasLength(1));
          checkCommand(list.single);
        },
      ),
      EndpointTest<GuildApplicationCommandManager, List<ApplicationCommand>, List<Object?>>(
        name: 'bulkOverride',
        method: 'PUT',
        source: [sampleCommand],
        urlMatcher: '/applications/0/guilds/1/commands',
        execute: (manager) => manager.bulkOverride([ApplicationCommandBuilder(name: 'TEST', type: ApplicationCommandType.chatInput)]),
        check: (list) {
          expect(list, hasLength(1));
          checkCommand(list.single);
        },
      ),
      EndpointTest<GuildApplicationCommandManager, List<CommandPermissions>, List<Object?>>(
        name: 'listCommandPermissions',
        source: [sampleCommandPermissions],
        urlMatcher: '/applications/0/guilds/1/commands/permissions',
        execute: (manager) => manager.listPermissions(),
        check: (list) {
          expect(list, hasLength(1));
          checkCommandPermissions(list.single);
        },
      ),
      EndpointTest<GuildApplicationCommandManager, CommandPermissions, Map<String, Object?>>(
        name: 'fetchCommandPermissions',
        source: sampleCommandPermissions,
        urlMatcher: '/applications/0/guilds/1/commands/2/permissions',
        execute: (manager) => manager.fetchPermissions(Snowflake(2)),
        check: checkCommandPermissions,
      ),
    ],
    createBuilder: ApplicationCommandBuilder(name: 'TEST', type: ApplicationCommandType.chatInput),
    updateBuilder: ApplicationCommandUpdateBuilder(),
  );
}
