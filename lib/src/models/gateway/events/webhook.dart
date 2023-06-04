import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/snowflake.dart';

class WebhooksUpdateEvent extends DispatchEvent {
  final Snowflake guildId;

  final Snowflake channelId;

  WebhooksUpdateEvent({required this.guildId, required this.channelId});
}
