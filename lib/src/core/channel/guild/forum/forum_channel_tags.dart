import 'package:nyxx/src/utils/permissions.dart';

abstract class IForumChannelTags {
  /// This thread is pinned to the top of its parent GUILD_FORUM channel
  bool get pinned;

  /// Whether a tag is required to be specified when creating a thread in a GUILD_FORUM channel.
  bool get requireTag;
}

class ForumChannelTags implements IForumChannelTags {
  @override
  late final bool pinned;

  @override
  late final bool requireTag;

  ForumChannelTags(int raw) {
    pinned = PermissionsUtils.isApplied(raw, 1 << 1);
    requireTag = PermissionsUtils.isApplied(raw, 1 << 4);
  }
}
