import 'dart:async';

import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/core/Snowflake.dart';
import 'package:nyxx/src/core/SnowflakeEntity.dart';
import 'package:nyxx/src/core/channel/Channel.dart';
import 'package:nyxx/src/core/channel/ITextChannel.dart';
import 'package:nyxx/src/core/message/Message.dart';
import 'package:nyxx/src/internal/cache/Cacheable.dart';
import 'package:nyxx/src/internal/interfaces/ISend.dart';
import 'package:nyxx/src/utils/builders/MessageBuilder.dart';

abstract class ICacheableTextChannel<T extends IChannel> implements IChannel, ITextChannel, ISend, Cacheable<Snowflake, T> {}

/// Lightweight channel which implements cacheable and allows to perform basic operation on channel instance
class CacheableTextChannel<S extends ITextChannel> extends Channel implements ICacheableTextChannel<S> {
  late Timer _typing;

  @override
  DateTime get createdAt => this.id.timestamp;

  /// Creates an instance of [CacheableTextChannel]
  CacheableTextChannel(INyxx client, Snowflake id, [ChannelType type = ChannelType.unknown]) : super.raw(client, id, type);

  @override
  S? getFromCache() => this.client.channels[this.id] as S;

  @override
  Future<S> download() => this.client.httpEndpoints.fetchChannel(this.id);

  @override
  FutureOr<S> getOrDownload() async => this.getFromCache() ?? await this.download();

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => this.client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Future<void> delete() => this.client.httpEndpoints.deleteChannel(this.id);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      this.client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake id) => this.client.httpEndpoints.fetchMessage(this.id, id);

  /// Returns always null since this type of channel doesn't have cache.
  @override
  IMessage? getMessage(Snowflake id) => null;

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => this.client.httpEndpoints.sendMessage(this.id, builder);

  @override
  Future<void> startTyping() => this.client.httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing.cancel();

  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(this.id);

  @override
  Future<void> dispose() async {
    // TODO: Empty body
  }

  @override
  Future<int> get fileUploadLimit =>
      throw UnimplementedError("CacheableTextChannel doesn't provide fileUploadLimit. Try getting channel from channel using methods from Cacheable");

  @override
  Map<Snowflake, IMessage> get messageCache =>
      throw UnimplementedError("CacheableTextChannel doesn't provide cache. Try getting channel from channel using methods from Cacheable");
}
