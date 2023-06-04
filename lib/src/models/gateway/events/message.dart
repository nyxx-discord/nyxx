import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/member.dart';
import 'package:nyxx/src/models/message/message.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/user/user.dart';

class MessageCreateEvent extends DispatchEvent {
  final Snowflake? guildId;

  final PartialMember? member;

  final List<User> mentions;

  final Message message;

  MessageCreateEvent({required this.guildId, required this.member, required this.mentions, required this.message});
}

class MessageUpdateEvent extends DispatchEvent {
  final Snowflake? guildId;

  final PartialMember? member;

  final List<User> mentions;

  final Message message;

  MessageUpdateEvent({required this.guildId, required this.member, required this.mentions, required this.message});
}

class MessageDeleteEvent extends DispatchEvent {
  final Snowflake id;

  final Snowflake channelId;

  final Snowflake? guildId;

  MessageDeleteEvent({required this.id, required this.channelId, required this.guildId});
}

class MessageBulkDeleteEvent extends DispatchEvent {
  final List<Snowflake> ids;

  final Snowflake channelId;

  final Snowflake? guildId;

  MessageBulkDeleteEvent({required this.ids, required this.channelId, required this.guildId});
}

class MessageReactionAddEvent extends DispatchEvent {
  final Snowflake userId;

  final Snowflake channelId;

  final Snowflake messageId;

  final Snowflake? guildId;

  final Member? member;

  // TODO
  //final PartialEmoji emoji;

  MessageReactionAddEvent({required this.userId, required this.channelId, required this.messageId, required this.guildId, required this.member});
}

class MessageReactionRemoveEvent extends DispatchEvent {
  final Snowflake userId;

  final Snowflake channelId;

  final Snowflake messageId;

  final Snowflake? guildId;

  // TODO
  //final PartialEmoji emoji;

  MessageReactionRemoveEvent({required this.userId, required this.channelId, required this.messageId, required this.guildId});
}

class MessageReactionRemoveAllEvent extends DispatchEvent {
  final Snowflake channelId;

  final Snowflake messageId;

  final Snowflake? guildId;

  MessageReactionRemoveAllEvent({required this.channelId, required this.messageId, required this.guildId});
}

class MessageReactionRemoveEmojiEvent extends DispatchEvent {
  final Snowflake channelId;

  final Snowflake messageId;

  final Snowflake? guildId;

  // TODO
  //final PartialEmoji emoji;

  MessageReactionRemoveEmojiEvent({required this.channelId, required this.messageId, required this.guildId});
}
