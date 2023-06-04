import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

class InviteCreateEvent extends DispatchEvent {
  // TODO
  //final Invite invite;
}

class InviteDeleteEvent extends DispatchEvent {
  final Snowflake channelId;

  final Snowflake? guildId;

  final String code;

  InviteDeleteEvent({required this.channelId, required this.guildId, required this.code});
}
