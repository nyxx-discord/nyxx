import 'package:nyxx/src/utils/permissions.dart';

/// Extra features of the message
class MessageFlags {
  /// Raw bitfield
  final int raw;

  /// This message has been published to subscribed channels (via Channel Following)
  bool get crossPosted => PermissionsUtils.isApplied(raw, 1 << 0);

  /// This message originated from a message in another channel (via Channel Following)
  bool get isCrossPost => PermissionsUtils.isApplied(raw, 1 << 1);

  /// Do not include any embeds when serializing this message
  bool get suppressEmbeds => PermissionsUtils.isApplied(raw, 1 << 2);

  /// The source message for this cross post has been deleted (via Channel Following)
  bool get sourceMessageDeleted => PermissionsUtils.isApplied(raw, 1 << 3);

  /// This message came from the urgent message system
  bool get urgent => PermissionsUtils.isApplied(raw, 1 << 4);

  /// This message has an associated thread, with the same id as the message
  bool get hasThread => PermissionsUtils.isApplied(raw, 1 << 5);

  /// This message is only visible to the user who invoked the Interaction
  bool get ephemeral => PermissionsUtils.isApplied(raw, 1 << 6);

  /// This message is an Interaction Response and the bot is "thinking"
  bool get loading => PermissionsUtils.isApplied(raw, 1 << 7);

  /// Creates an instance of [MessageFlags]
  MessageFlags(this.raw);
}
