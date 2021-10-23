
import 'dart:async';

import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/core/user/User.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/MessageBuilder.dart';

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
  bool get isGroupDM => this.participants.length > 1;

  /// List of participants in channel. If not group dm channel it will only return other user in chat.
  @override
  late final Iterable<IUser> participants;

  /// Returns other user in chat if channel is not group dm. Will throw [ArgumentError] if channel is group dm.
  @override
  IUser get participant => !this.isGroupDM ? participants.first : throw new ArgumentError("Channel is not direct DM");

  /// Creates an instance of [DMChannel]
  DMChannel(INyxx client, RawApiMap raw): super(client, raw) {
    if (raw["recipients"] != null) {
      this.participants = [
        for (final userRaw in raw["recipients"])
          User(this.client, userRaw as RawApiMap)
      ];
    } else {
      this.participants = [
        User(client, raw["recipient"] as RawApiMap)
      ];
    }
  }

  @override
  Future<void> startTyping() async =>
      client.httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing?.cancel();

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) =>
      client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(this.id, messageId);

    if(client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      this.messageCache[messageId] = message;
    }

    return message;
  }

  @override
  Stream<IMessage> fetchPinnedMessages() =>
      client.httpEndpoints.fetchPinnedMessages(this.id);

  @override
  IMessage? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) =>
      client.httpEndpoints.sendMessage(this.id,builder);

}
