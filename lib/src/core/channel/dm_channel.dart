import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

abstract class IDMChannel implements IChannel, ITextChannel {
  @override
  Future<int> get fileUploadLimit async => 8 * 1024 * 1024;

  /// True if channel is group dm
  bool get isGroupDM;

  /// List of participants in channel. If not group dm channel it will only return other user in chat.
  Iterable<IUser> get participants;

  /// Returns other user in chat if channel is not group dm. Will throw [ArgumentError] if channel is group dm.
  IUser get participant;
}

/// Represents private channel with user
class DMChannel extends Channel implements IDMChannel {
  @override
  late final Map<Snowflake, IMessage> messageCache = {};

  @override
  Future<int> get fileUploadLimit async => 8 * 1024 * 1024;

  // Used to create infinite typing loop
  Timer? _typing;

  /// True if channel is group dm
  @override
  bool get isGroupDM => participants.length > 1;

  /// List of participants in channel. If not group dm channel it will only return other user in chat.
  @override
  late final Iterable<IUser> participants;

  /// Returns other user in chat if channel is not group dm. Will throw [ArgumentError] if channel is group dm.
  @override
  IUser get participant => !isGroupDM ? participants.first : throw ArgumentError("Channel is not direct DM");

  /// Creates an instance of [DMChannel]
  DMChannel(INyxx client, RawApiMap raw) : super(client, raw) {
    if (raw["recipients"] != null) {
      participants = [for (final userRaw in raw["recipients"] as RawApiList) User(this.client, userRaw as RawApiMap)];
    } else {
      participants = [User(client, raw["recipient"] as RawApiMap)];
    }
  }

  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(id);

  @override
  void startTypingLoop() {
    startTyping();
    _typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => _typing?.cancel();

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(id, messageId);

    if (client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      messageCache[messageId] = message;
    }

    return message;
  }

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(id);

  @override
  IMessage? getMessage(Snowflake id) => messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(id, builder);
}
