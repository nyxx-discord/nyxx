import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/member.mock.dart';
import '../mocks/message.mock.dart';
import '../mocks/nyxx_rest.mock.dart';

main() {
  test("ThreadBuilder", () {
    final publicBuilder = ThreadBuilder('test name')
      ..archiveAfter = ThreadArchiveTime.threeDays
      ..private = false;
    expect(publicBuilder.build(), equals({"auto_archive_duration": ThreadArchiveTime.threeDays.value, "name": 'test name', "type": 11}));

    final privateBuilder = ThreadBuilder("second name")..private = true;
    expect(privateBuilder.build(), equals({"name": 'second name', "type": 12}));
  });

  test('StickerBuilder', () {
    final builder = StickerBuilder()
      ..name = "this is name"
      ..description = "this is description"
      ..tags = "tags";

    expect(builder.build(), equals({"name": "this is name", "description": "this is description", "tags": "tags"}));
  });

  test("ReplyBuilder", () {
    final basicBuilder = ReplyBuilder(Snowflake.zero());
    expect(basicBuilder.build(), equals({"message_id": '0', "fail_if_not_exists": false}));

    final messageBuilder = ReplyBuilder.fromMessage(MockMessage({"content": "content"}, Snowflake(123)));
    expect(messageBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": false}));

    final messageCacheable = MessageCacheable(NyxxRestEmptyMock(), Snowflake(123), ChannelCacheable<ITextChannel>(NyxxRestEmptyMock(), Snowflake(456)));
    final cacheableBuilder = ReplyBuilder.fromCacheable(messageCacheable, true);
    expect(cacheableBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": true}));
  });

  group('presence_builder.dart', () {
    test('PresenceBuilder', () {
      final activityBuilder = ActivityBuilder.game("test game name");

      final ofBuilder = PresenceBuilder.of(status: UserStatus.dnd, activity: activityBuilder);
      expect(
          ofBuilder.build(),
          equals({
            'status': UserStatus.dnd.toString(),
            'activities': [
              {
                "name": "test game name",
                "type": ActivityType.game.value,
              }
            ],
            'afk': false,
            'since': null,
          }));

      final now = DateTime.now();
      final idleBuilder = PresenceBuilder.idle(since: now);

      expect(
          idleBuilder.build(),
          equals({
            'status': UserStatus.idle.toString(),
            'afk': true,
            'since': now.millisecondsSinceEpoch,
          }));
    });

    test('ActivityBuilder', () {
      final streamingBuilder = ActivityBuilder.streaming("test game name", 'https://twitch.tv');
      expect(streamingBuilder.build(), equals({"name": "test game name", "type": ActivityType.streaming.value, "url": 'https://twitch.tv'}));

      final listeningBuilder = ActivityBuilder.listening("test listening name");
      expect(
          listeningBuilder.build(),
          equals({
            "name": "test listening name",
            "type": ActivityType.listening.value,
          }));
    });
  });

  test('PermissionOverrideBuilder', () {
    final builder = PermissionOverrideBuilder(0, Snowflake.zero());
    expect(builder.build().build(), equals({"allow": 0, "deny": 0}));

    final fromBuilder = PermissionOverrideBuilder.from(0, Snowflake.zero(), Permissions.empty());
    expect(fromBuilder.build().build(), equals({"allow": 0, "deny": 122406567679}));
    expect(fromBuilder.calculatePermissionValue(), equals(0));

    final ofBuilder = PermissionOverrideBuilder.of(MockMember(Snowflake.zero()))
      ..sendMessages = true
      ..addReactions = false;

    expect(ofBuilder.build().build(), equals({"allow": 1 << 11, "deny": 1 << 6}));
    expect(ofBuilder.calculatePermissionValue(), equals(1 << 11));
  });
}
