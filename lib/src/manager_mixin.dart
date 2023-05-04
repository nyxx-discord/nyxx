import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/managers/channel_manager.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';
import 'package:nyxx/src/http/managers/webhook_manager.dart';

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
}
