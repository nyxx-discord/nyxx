import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/channel/thread.dart';
import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/channel/thread_list.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/utils/flags.dart';

class PartialChannel extends SnowflakeEntity<Channel> with SnowflakeEntityMixin<Channel> {
  @override
  final ChannelManager manager;

  late final MessageManager messages = MessageManager(manager.client.options.messageCacheConfig, manager.client, channelId: id);

  PartialChannel({required super.id, required this.manager});

  Future<Message> sendMessage(MessageBuilder builder) => messages.create(builder);

  Future<Channel> update(UpdateBuilder<Channel> builder) => manager.update(id, builder);

  Future<void> delete({String? auditLogReason}) => manager.delete(id, auditLogReason: auditLogReason);

  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder) => manager.updatePermissionOverwrite(id, builder);

  Future<void> deletePermissionOverwrite(Snowflake id) => manager.deletePermissionOverwrite(this.id, id);

  Future<void> follow(Snowflake id) => manager.followChannel(this.id, id);

  Future<void> triggerTyping() => manager.triggerTyping(id);

  Future<Thread> createThreadFromMessage(Snowflake messageId, ThreadFromMessageBuilder builder) => manager.createThreadFromMessage(id, messageId, builder);

  Future<Thread> createThread(ThreadBuilder builder) => manager.createThread(id, builder);

  Future<Thread> createForumThread(ForumThreadBuilder builder) => manager.createForumThread(id, builder);

  Future<void> addThreadMember(Snowflake memberId) => manager.addThreadMember(id, memberId);

  Future<void> removeThreadMember(Snowflake memberId) => manager.removeThreadMember(id, memberId);

  Future<void> fetchThreadMember(Snowflake memberId) => manager.fetchThreadMember(id, memberId);

  Future<List<ThreadMember>> listThreadMembers({bool? withMembers, Snowflake? after, int? limit}) => manager.listThreadMembers(
        id,
        after: after,
        limit: limit,
        withMembers: withMembers,
      );

  Future<ThreadList> listPublicArchivedThreads({DateTime? before, int? limit}) => manager.listPublicArchivedThreads(
        id,
        before: before,
        limit: limit,
      );

  Future<ThreadList> listPrivateArchivedThreads({DateTime? before, int? limit}) => manager.listPrivateArchivedThreads(
        id,
        before: before,
        limit: limit,
      );
}

abstract class Channel extends PartialChannel {
  ChannelType get type;

  Channel({required super.id, required super.manager});
}

enum ChannelType {
  guildText._(0),
  dm._(1),
  guildVoice._(2),
  groupDm._(3),
  guildCategory._(4),
  guildAnnouncement._(5),
  announcementThread._(10),
  publicThread._(11),
  privateThread._(12),
  guildStageVoice._(13),
  guildDirectory._(14),
  guildForum._(15);

  final int value;

  const ChannelType._(this.value);

  factory ChannelType.parse(int value) => ChannelType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown channel type', value),
      );

  @override
  String toString() => 'ChannelType($value)';
}

// Currently only used in forum channels and threads
class ChannelFlags extends Flags<ChannelFlags> {
  static const pinned = Flag<ChannelFlags>.fromOffset(1);
  static const requireTag = Flag<ChannelFlags>.fromOffset(4);

  bool get isPinned => has(pinned);
  bool get requiresTag => has(requireTag);

  const ChannelFlags(super.value);
}
