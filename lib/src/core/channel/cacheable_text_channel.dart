import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/channel.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/interfaces/send.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

abstract class ICacheableTextChannel<T extends IChannel> implements IChannel, ITextChannel, ISend, Cacheable<Snowflake, T> {}

/// Lightweight channel which implements cacheable and allows to perform basic operation on channel instance
class CacheableTextChannel<S extends ITextChannel> extends Channel implements ICacheableTextChannel<S> {
  late Timer _typing;

  @override
  DateTime get createdAt => id.timestamp;

  /// Creates an instance of [CacheableTextChannel]
  CacheableTextChannel(INyxx client, Snowflake id, [ChannelType type = ChannelType.unknown]) : super.raw(client, id, type);

  @override
  S? getFromCache() {
    final cached = client.channels[id];

    if (cached is S) {
      return cached;
    }

    return null;
  }

  @override
  Future<S> download() => client.httpEndpoints.fetchChannel(id);

  @override
  FutureOr<S> getOrDownload() async => getFromCache() ?? await download();

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(id, messages);

  @override
  Future<void> delete() => client.httpEndpoints.deleteChannel(id);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake id) => client.httpEndpoints.fetchMessage(this.id, id);

  /// Returns always null since this type of channel doesn't have cache.
  @override
  IMessage? getMessage(Snowflake id) => null;

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(id, builder);

  @override
  Future<void> startTyping() => client.httpEndpoints.triggerTyping(id);

  @override
  void startTypingLoop() {
    startTyping();
    _typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => _typing.cancel();

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(id);

  @override
  Future<void> dispose() async {}

  @override
  Future<int> get fileUploadLimit =>
      throw UnimplementedError("CacheableTextChannel doesn't provide fileUploadLimit. Try getting channel from channel using methods from Cacheable");

  @override
  Map<Snowflake, IMessage> get messageCache =>
      throw UnimplementedError("CacheableTextChannel doesn't provide cache. Try getting channel from channel using methods from Cacheable");
}
