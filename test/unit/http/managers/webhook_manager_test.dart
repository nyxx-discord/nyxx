import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../../test_manager.dart';
import 'message_manager_test.dart';

final sampleIncomingWebhook = {
  "name": "test webhook",
  "type": 1,
  "channel_id": "199737254929760256",
  "token": "3d89bb7572e0fb30d8128367b3b1b44fecd1726de135cbe28a41f8b2f777c372ba2939e72279b94526ff5d1bd4358d65cf11",
  "avatar": null,
  "guild_id": "199737254929760256",
  "id": "223704706495545344",
  "application_id": null,
  "user": {"username": "test", "discriminator": "7479", "id": "190320984123768832", "avatar": "b004ec1740a63ca06ae2e14c5cee11f3", "public_flags": 131328}
};

void checkIncomingWebhook(Webhook webhook) {
  expect(webhook.id, equals(Snowflake(223704706495545344)));
  expect(webhook.type, equals(WebhookType.incoming));
  expect(webhook.guildId, equals(Snowflake(199737254929760256)));
  expect(webhook.channelId, equals(Snowflake(199737254929760256)));
  expect(webhook.user?.id, equals(Snowflake(190320984123768832)));
  expect(webhook.name, equals('test webhook'));
  expect(webhook.avatarHash, isNull);
  expect(webhook.token, equals('3d89bb7572e0fb30d8128367b3b1b44fecd1726de135cbe28a41f8b2f777c372ba2939e72279b94526ff5d1bd4358d65cf11'));
  expect(webhook.applicationId, isNull);
  expect(webhook.sourceChannel, isNull);
  expect(webhook.url, isNull);
}

final sampleChannelFollowerWebhook = {
  "type": 2,
  "id": "752831914402115456",
  "name": "Guildy name",
  "avatar": "bb71f469c158984e265093a81b3397fb",
  "channel_id": "561885260615255432",
  "guild_id": "56188498421443265",
  "application_id": null,
  "source_guild": {"id": "56188498421476534", "name": "Guildy name", "icon": "bb71f469c158984e265093a81b3397fb"},
  "source_channel": {"id": "5618852344134324", "name": "announcements"},
  "user": {"username": "test", "discriminator": "7479", "id": "190320984123768832", "avatar": "b004ec1740a63ca06ae2e14c5cee11f3", "public_flags": 131328}
};

void checkChannelFollowerWebhook(Webhook webhook) {
  expect(webhook.id, equals(Snowflake(752831914402115456)));
  expect(webhook.type, equals(WebhookType.channelFollower));
  expect(webhook.guildId, equals(Snowflake(56188498421443265)));
  expect(webhook.channelId, equals(Snowflake(561885260615255432)));
  expect(webhook.user?.id, equals(Snowflake(190320984123768832)));
  expect(webhook.name, equals('Guildy name'));
  expect(webhook.avatarHash, equals('bb71f469c158984e265093a81b3397fb'));
  expect(webhook.token, isNull);
  expect(webhook.applicationId, isNull);
  expect(webhook.sourceChannel?.id, equals(Snowflake(5618852344134324)));
  expect(webhook.url, isNull);
}

final sampleApplicationWebhook = {
  "type": 3,
  "id": "658822586720976555",
  "name": "Clyde",
  "avatar": "689161dc90ac261d00f1608694ac6bfd",
  "channel_id": null,
  "guild_id": null,
  "application_id": "658822586720976555"
};

void checkApplicationWebhook(Webhook webhook) {
  expect(webhook.id, equals(Snowflake(658822586720976555)));
  expect(webhook.type, equals(WebhookType.application));
  expect(webhook.guildId, isNull);
  expect(webhook.channelId, isNull);
  expect(webhook.user, isNull);
  expect(webhook.name, equals('Clyde'));
  expect(webhook.avatarHash, equals('689161dc90ac261d00f1608694ac6bfd'));
  expect(webhook.token, isNull);
  expect(webhook.applicationId, equals(Snowflake(658822586720976555)));
  expect(webhook.sourceChannel, isNull);
  expect(webhook.url, isNull);
}

void main() {
  testManager<Webhook, WebhookManager>(
    'WebhookManager',
    WebhookManager.new,
    RegExp(r'/webhooks/\d+'),
    RegExp(r'/channels/\d+/webhooks'),
    sampleObject: sampleIncomingWebhook,
    sampleMatches: checkIncomingWebhook,
    additionalSampleObjects: [sampleChannelFollowerWebhook, sampleApplicationWebhook],
    additionalSampleMatchers: [checkChannelFollowerWebhook, checkApplicationWebhook],
    additionalParsingTests: [],
    additionalEndpointTests: [
      EndpointTest<WebhookManager, List<Webhook>, List<Object?>>(
        name: 'fetchChannelWebhooks',
        source: [sampleApplicationWebhook, sampleIncomingWebhook, sampleChannelFollowerWebhook],
        urlMatcher: '/channels/0/webhooks',
        execute: (manager) => manager.fetchChannelWebhooks(Snowflake(0)),
        check: (webhooks) {
          expect(webhooks, hasLength(3));

          checkApplicationWebhook(webhooks[0]);
          checkIncomingWebhook(webhooks[1]);
          checkChannelFollowerWebhook(webhooks[2]);
        },
      ),
      EndpointTest<WebhookManager, List<Webhook>, List<Object?>>(
        name: 'fetchGuildWebhooks',
        source: [sampleApplicationWebhook, sampleIncomingWebhook, sampleChannelFollowerWebhook],
        urlMatcher: '/guilds/0/webhooks',
        execute: (manager) => manager.fetchGuildWebhooks(Snowflake(0)),
        check: (webhooks) {
          expect(webhooks, hasLength(3));

          checkApplicationWebhook(webhooks[0]);
          checkIncomingWebhook(webhooks[1]);
          checkChannelFollowerWebhook(webhooks[2]);
        },
      ),
      EndpointTest<WebhookManager, void, void>(
        name: 'execute (no wait)',
        source: null,
        urlMatcher: '/webhooks/0/token',
        method: 'POST',
        execute: (manager) => manager.execute(Snowflake(0), MessageBuilder(content: 'foo'), token: 'token'),
        check: (_) {},
      ),
      EndpointTest<WebhookManager, Message?, Map<String, Object?>>(
        name: 'execute (wait)',
        source: sampleMessage,
        urlMatcher: '/webhooks/0/token?wait=true',
        method: 'POST',
        execute: (manager) => manager.execute(Snowflake(0), MessageBuilder(content: 'foo'), token: 'token', wait: true),
        check: (message) {
          expect(message, isNotNull);
          checkMessage(message!);
        },
      ),
      EndpointTest<WebhookManager, Message, Map<String, Object?>>(
        name: 'fetchWebhookMessage',
        source: sampleMessage,
        urlMatcher: '/webhooks/0/token/messages/1',
        execute: (manager) => manager.fetchWebhookMessage(Snowflake(0), Snowflake(1), token: 'token'),
        check: checkMessage,
      ),
      EndpointTest<WebhookManager, Message, Map<String, Object?>>(
        name: 'updateWebhookMessage',
        source: sampleMessage,
        urlMatcher: '/webhooks/0/token/messages/1',
        method: 'PATCH',
        execute: (manager) => manager.updateWebhookMessage(Snowflake(0), Snowflake(1), MessageUpdateBuilder(), token: 'token'),
        check: checkMessage,
      ),
      EndpointTest<WebhookManager, void, void>(
        name: 'deleteWebhookMessage',
        source: null,
        urlMatcher: '/webhooks/0/token/messages/1',
        method: 'DELETE',
        execute: (manager) => manager.deleteWebhookMessage(Snowflake(0), Snowflake(1), token: 'token'),
        check: (_) {},
      ),
    ],
    createBuilder: WebhookBuilder(name: 'Test webhook', channelId: Snowflake(0)),
    updateBuilder: WebhookUpdateBuilder(name: 'Updated test webhook'),
  );
}
