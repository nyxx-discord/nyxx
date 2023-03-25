import 'package:nyxx/src/client.dart';
import 'package:nyxx/src/client_options.dart';
import 'package:nyxx/src/http/managers/user_manager.dart';

/// An internal mixin to add managers to a [Nyxx] instance.
mixin ManagerMixin implements Nyxx {
  @override
  RestClientOptions get options;

  /// A [UserManager] that manages users for this client.
  late final UserManager users = UserManager(options.userCacheConfig, this as NyxxRest);
}
