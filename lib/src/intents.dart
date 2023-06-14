import 'package:nyxx/src/utils/flags.dart';

/// Flags used to set the intents when opening a Gateway session.
class GatewayIntents extends Flags<GatewayIntents> {
  static final guilds = Flag<GatewayIntents>.fromOffset(0);
  static final guildMembers = Flag<GatewayIntents>.fromOffset(1);
  static final guildModeration = Flag<GatewayIntents>.fromOffset(2);
  static final guildEmojisAndStickers = Flag<GatewayIntents>.fromOffset(3);
  static final guildIntegrations = Flag<GatewayIntents>.fromOffset(4);
  static final guildWebhooks = Flag<GatewayIntents>.fromOffset(5);
  static final guildInvites = Flag<GatewayIntents>.fromOffset(6);
  static final guildVoiceStates = Flag<GatewayIntents>.fromOffset(7);
  static final guildPresences = Flag<GatewayIntents>.fromOffset(8);
  static final guildMessages = Flag<GatewayIntents>.fromOffset(9);
  static final guildMessageReactions = Flag<GatewayIntents>.fromOffset(10);
  static final guildMessageTyping = Flag<GatewayIntents>.fromOffset(11);
  static final directMessages = Flag<GatewayIntents>.fromOffset(12);
  static final directMessageReactions = Flag<GatewayIntents>.fromOffset(13);
  static final directMessageTyping = Flag<GatewayIntents>.fromOffset(14);
  static final messageContent = Flag<GatewayIntents>.fromOffset(15);
  static final guildScheduledEvents = Flag<GatewayIntents>.fromOffset(16);
  static final autoModerationConfiguration = Flag<GatewayIntents>.fromOffset(20);
  static final autoModerationExecution = Flag<GatewayIntents>.fromOffset(21);

  /// A [GatewayIntents] with all intents enabled.
  static final all = GatewayIntents(BigInt.from(0x1fffff));

  /// A [GatewayIntents] with all unprivileged intents enabled.
  static final allUnprivileged = GatewayIntents(BigInt.from(0x317efd));

  /// A [GatewayIntents] with all privileged intents enabled.
  static final allPrivileged = GatewayIntents(BigInt.from(0x8102));

  /// A [GatewayIntents] with no intents enabled.
  static final none = GatewayIntents(BigInt.zero);

  /// Create a new [GatewayIntents].
  GatewayIntents(super.value);
}
