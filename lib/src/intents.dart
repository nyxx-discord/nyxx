import 'package:nyxx/src/utils/flags.dart';

/// Flags used to set the intents when opening a Gateway session.
class GatewayIntents extends Flags<GatewayIntents> {
  static const guilds = Flag<GatewayIntents>.fromOffset(0);
  static const guildMembers = Flag<GatewayIntents>.fromOffset(1);
  static const guildModeration = Flag<GatewayIntents>.fromOffset(2);
  static const guildExpressions = Flag<GatewayIntents>.fromOffset(3);
  @Deprecated('Use GatewayIntents.guildExpressions instead')
  static const guildEmojisAndStickers = guildExpressions;
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
  static const guildMessagePolls = Flag<GatewayIntents>.fromOffset(24);
  static const directMessagePolls = Flag<GatewayIntents>.fromOffset(25);

  /// A [GatewayIntents] with all intents enabled.
  static const all = GatewayIntents(0x331ffff);

  /// A [GatewayIntents] with all unprivileged intents enabled.
  static const allUnprivileged = GatewayIntents(0x3317efd);

  /// A [GatewayIntents] with all privileged intents enabled.
  static const allPrivileged = GatewayIntents(0x8102);

  /// A [GatewayIntents] with no intents enabled.
  static const none = GatewayIntents(0);

  /// Create a new [GatewayIntents].
  const GatewayIntents(super.value);
}
