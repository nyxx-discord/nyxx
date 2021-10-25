import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/channel/thread_channel.dart';
import 'package:nyxx/src/core/channel/thread_preview_channel.dart';
import 'package:nyxx/src/core/channel/guild/guild_channel.dart';
import 'package:nyxx/src/core/guild/webhook.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/internal/cache/cache.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/internal/response_wrapper/thread_list_result_wrapper.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';

abstract class ITextGuildChannel implements IGuildChannel, ITextChannel, Mentionable {
  /// The channel's topic.
  String? get topic;

  /// Channel's slow mode rate limit in seconds. This must be between 0 and 120.
  int get slowModeThreshold;

  /// Returns url to this channel.
  String get url;

  /// Gets all of the webhooks for this channel.
  Stream<IWebhook> getWebhooks();

  /// Creates a webhook for channel.
  /// Valid file types for [avatarFile] are jpeg, gif and png.
  ///
  /// ```
  /// final webhook = await channnel.createWebhook("!a Send nudes kek6407");
  /// ```
  Future<IWebhook> createWebhook(String name, {AttachmentBuilder? avatarAttachment, String? auditReason});

  /// Creates a thread in a channel, that only retrieves a [ThreadPreviewChannel]
  Future<IThreadPreviewChannel> createThread(ThreadBuilder builder);

  /// Creates a thread in a message
  Future<IThreadChannel> createAndGetThread(ThreadBuilder builder);

  /// Fetches all active threads in this channel
  Future<IThreadListResultWrapper> fetchActiveThreads();

  /// Fetches joined private and archived thread channels
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads({DateTime? before, int? limit});

  /// Fetches private, archived thread channels
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads({DateTime? before, int? limit});

  /// Fetches public, archives thread channels
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads({DateTime? before, int? limit});
}

class TextGuildChannel extends GuildChannel implements ITextGuildChannel {
  /// The channel's topic.
  @override
  late final String? topic;

  /// The channel's mention string.
  @override
  String get mention => "<#${this.id}>";

  /// Channel's slow mode rate limit in seconds. This must be between 0 and 120.
  @override
  late final int slowModeThreshold;

  /// Returns url to this channel.
  @override
  String get url => "https://discordapp.com/channels/${this.guild.id.toString()}"
      "/${this.id.toString()}";

  @override
  late final MessageCache messageCache = MessageCache(client.options.messageCacheSize);

  @override
  Future<int> get fileUploadLimit async {
    final guildInstance = await this.guild.getOrDownload();

    return guildInstance.fileUploadLimit;
  }

  // Used to create infinite typing loop
  Timer? _typing;

  /// Creates an instance of [TextGuildChannel]
  TextGuildChannel(INyxx client, RawApiMap raw, [Snowflake? guildId]) : super(client, raw, guildId) {
    this.topic = raw["topic"] as String?;
    this.slowModeThreshold = raw["rate_limit_per_user"] as int? ?? 0;
  }

  /// Gets all of the webhooks for this channel.
  @override
  Stream<IWebhook> getWebhooks() => client.httpEndpoints.fetchChannelWebhooks(this.id);

  /// Creates a webhook for channel.
  /// Valid file types for [avatarFile] are jpeg, gif and png.
  ///
  /// ```
  /// final webhook = await channnel.createWebhook("!a Send nudes kek6407");
  /// ```
  @override
  Future<IWebhook> createWebhook(String name, {AttachmentBuilder? avatarAttachment, String? auditReason}) =>
      client.httpEndpoints.createWebhook(this.id, name, avatarAttachment: avatarAttachment, auditReason: auditReason);

  /// Returns pinned [Message]s for channel.
  @override
  Stream<IMessage> fetchPinnedMessages() => client.httpEndpoints.fetchPinnedMessages(this.id);

  /// Creates a thread in a channel, that only retrieves a [ThreadPreviewChannel]
  @override
  Future<IThreadPreviewChannel> createThread(ThreadBuilder builder) => client.httpEndpoints.createThread(this.id, builder);

  /// Creates a thread in a message
  @override
  Future<IThreadChannel> createAndGetThread(ThreadBuilder builder) async {
    final preview = await client.httpEndpoints.createThread(this.id, builder);
    return preview.getThreadChannel().getOrDownload();
  }

  @override
  Future<void> startTyping() async => client.httpEndpoints.triggerTyping(this.id);

  @override
  void startTypingLoop() {
    startTyping();
    this._typing = Timer.periodic(const Duration(seconds: 7), (Timer t) => startTyping());
  }

  @override
  void stopTypingLoop() => this._typing?.cancel();

  @override
  Future<void> bulkRemoveMessages(Iterable<SnowflakeEntity> messages) => client.httpEndpoints.bulkRemoveMessages(this.id, messages);

  @override
  Stream<IMessage> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) =>
      client.httpEndpoints.downloadMessages(this.id, limit: limit, after: after, around: around, before: before);

  @override
  Future<IMessage> fetchMessage(Snowflake messageId) async {
    final message = await client.httpEndpoints.fetchMessage(this.id, messageId);

    if (client.cacheOptions.messageCachePolicyLocation.http && client.cacheOptions.messageCachePolicy.canCache(message)) {
      this.messageCache.put(message);
    }

    return message;
  }

  @override
  IMessage? getMessage(Snowflake id) => this.messageCache[id];

  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => client.httpEndpoints.sendMessage(this.id, builder);

  /// Fetches all active threads in this channel
  @override
  Future<IThreadListResultWrapper> fetchActiveThreads() => client.httpEndpoints.fetchActiveThreads(this.id);

  /// Fetches joined private and archived thread channels
  @override
  Future<IThreadListResultWrapper> fetchJoinedPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchJoinedPrivateArchivedThreads(this.id, before: before, limit: limit);

  /// Fetches private, archived thread channels
  @override
  Future<IThreadListResultWrapper> fetchPrivateArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPrivateArchivedThreads(this.id, before: before, limit: limit);

  /// Fetches public, archives thread channels
  @override
  Future<IThreadListResultWrapper> fetchPublicArchivedThreads({DateTime? before, int? limit}) =>
      client.httpEndpoints.fetchPublicArchivedThreads(this.id, before: before, limit: limit);
}
