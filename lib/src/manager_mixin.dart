import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/managers/application_command_manager.dart';
import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/http/managers/interaction_manager.dart';
import 'package:nyxx/src/http/managers/invite_manager.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/http/managers/soundboard_manager.dart';
import 'package:nyxx/src/http/managers/sticker_manager.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';
import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/http/managers/voice_manager.dart';

/// An internal mixin to add managers to a [Nyxx] instance.
mixin ManagerMixin implements Nyxx {
  @override
  RestClientOptions get options;

  /// A [UserManager] that manages users for this client.
  UserManager get users => _users;
  late final UserManager _users = UserManager(options.userCacheConfig, this as NyxxRest);

  /// A [ChannelManager] that manages channels for this client.
  ChannelManager get channels => _channels;
  late final ChannelManager _channels = ChannelManager(options.channelCacheConfig, this as NyxxRest, stageInstanceConfig: options.stageInstanceCacheConfig);

  /// A [WebhookManager] that manages webhooks for this client.
  WebhookManager get webhooks => _webhooks;
  late final WebhookManager _webhooks = WebhookManager(options.webhookCacheConfig, this as NyxxRest);

  /// A [GuildManager] that manages guilds for this client.
  GuildManager get guilds => _guilds;
  late final GuildManager _guilds = GuildManager(options.guildCacheConfig, this as NyxxRest);

  /// An [ApplicationManager] that manages applications for this client.
  ApplicationManager get applications => _applications;
  late final ApplicationManager _applications = ApplicationManager(this as NyxxRest);

  /// A [VoiceManager] that manages voice states for this client.
  VoiceManager get voice => _voice;
  late final VoiceManager _voice = VoiceManager(this as NyxxRest);

  /// An [InviteManager] that manages invites for this client.
  InviteManager get invites => _invites;
  late final InviteManager _invites = InviteManager(this as NyxxRest);

  /// A [GatewayManager] that manages gateway metadata for this client.
  GatewayManager get gateway => _gateway;
  late final GatewayManager _gateway = GatewayManager(this as NyxxRest);

  /// A [GlobalStickerManager] that manages global stickers.
  GlobalStickerManager get stickers => _stickers;
  late final GlobalStickerManager _stickers = GlobalStickerManager(options.globalStickerCacheConfig, this as NyxxRest);

  /// A [GlobalApplicationCommandManager] that manages global application commands.
  GlobalApplicationCommandManager get commands => _commands;
  late final GlobalApplicationCommandManager _commands =
      GlobalApplicationCommandManager(options.applicationCommandConfig, this as NyxxRest, applicationId: (this as NyxxRest).application.id);

  /// An [InteractionManager] that manages interactions received by the client.
  InteractionManager get interactions => _interactions;
  late final InteractionManager _interactions = InteractionManager(this as NyxxRest, applicationId: (this as NyxxRest).application.id);

  /// A [GlobalSoundboardManager] that manages global soundboard sounds.
  GlobalSoundboardManager get soundboard => _soundboard;
  late final GlobalSoundboardManager _soundboard = GlobalSoundboardManager(options.globalSoundboardCacheConfig, this as NyxxRest);
}
