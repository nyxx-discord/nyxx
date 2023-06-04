import 'package:nyxx/src/utils/flags.dart';

class GatewayIntents extends Flags<GatewayIntents> {
  static const guilds = Flag<GatewayIntents>.fromOffset(0);
  static const guildMembers = Flag<GatewayIntents>.fromOffset(1);
  static const guildModeration = Flag<GatewayIntents>.fromOffset(2);
  static const guildEmojisAndStickers = Flag<GatewayIntents>.fromOffset(3);
  static const guildIntegrations = Flag<GatewayIntents>.fromOffset(4);
  static const guildWebhooks = Flag<GatewayIntents>.fromOffset(5);
  static const guildInvites = Flag<GatewayIntents>.fromOffset(6);
  static const guildVoiceStates = Flag<GatewayIntents>.fromOffset(7);
  static const guildPresences = Flag<GatewayIntents>.fromOffset(8);
  static const guildMessages = Flag<GatewayIntents>.fromOffset(9);
  static const guildMessageReactions = Flag<GatewayIntents>.fromOffset(10);
  static const guildMessageTyping = Flag<GatewayIntents>.fromOffset(11);
  static const directMessages = Flag<GatewayIntents>.fromOffset(12);
  static const directMessageReactions = Flag<GatewayIntents>.fromOffset(13);
  static const directMessageTyping = Flag<GatewayIntents>.fromOffset(14);
  static const messageContent = Flag<GatewayIntents>.fromOffset(15);
  static const guildScheduledEvents = Flag<GatewayIntents>.fromOffset(16);
  static const autoModerationConfiguration = Flag<GatewayIntents>.fromOffset(20);
  static const autoModerationExecution = Flag<GatewayIntents>.fromOffset(21);

  static const all = GatewayIntents(0x1fffff);
  static const allUnprivileged = GatewayIntents(0x317efd);
  static const allPrivileged = GatewayIntents(0x8102);

  const GatewayIntents(super.value);
}
