import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/http/managers/gateway_manager.dart';
import 'package:nyxx/src/http/managers/guild_manager.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';
import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/http/managers/voice_manager.dart';

/// An internal mixin to add managers to a [Nyxx] instance.
mixin ManagerMixin implements Nyxx {
  @override
  RestClientOptions get options;

  /// A [UserManager] that manages users for this client.
  UserManager get users => UserManager(options.userCacheConfig, this as NyxxRest);

  /// A [ChannelManager] that manages channels for this client.
  ChannelManager get channels => ChannelManager(options.channelCacheConfig, this as NyxxRest);

  /// A [WebhookManager] that manages webhooks for this client.
  WebhookManager get webhooks => WebhookManager(options.webhookCacheConfig, this as NyxxRest);

  /// A [GuildManager] that manages guilds for this client.
  GuildManager get guilds => GuildManager(options.guildCacheConfig, this as NyxxRest, banConfig: options.banCacheConfig);

  /// An [ApplicationManager] that manages applications for this client.
  ApplicationManager get applications => ApplicationManager(this as NyxxRest);

  /// A [VoiceManager] that manages voice states for this client.
  VoiceManager get voice => VoiceManager(this as NyxxRest);

  /// A [GatewayManager] that manages gateway metadata for this client.
  GatewayManager get gateway => GatewayManager(this as NyxxRest);
}
