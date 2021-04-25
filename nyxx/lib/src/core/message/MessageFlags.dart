part of nyxx;

/// Extra features of the message
class MessageFlags {
  /// This message has been published to subscribed channels (via Channel Following)
  late final bool crossPosted;

  /// This message originated from a message in another channel (via Channel Following)
  late final bool isCrossPost;

  /// Do not include any embeds when serializing this message
  late final bool suppressEmbeds;

  /// The source message for this crosspost has been deleted (via Channel Following)
  late final bool sourceMessageDeleted;

  /// This message came from the urgent message system
  late final bool urgent;

  MessageFlags._new(int raw) {
    this.crossPosted = PermissionsUtils.isApplied(raw, 1 << 0);
    this.isCrossPost = PermissionsUtils.isApplied(raw, 1 << 1);
    this.suppressEmbeds = PermissionsUtils.isApplied(raw, 1 << 2);
    this.sourceMessageDeleted = PermissionsUtils.isApplied(raw, 1 << 3);
    this.urgent = PermissionsUtils.isApplied(raw, 1 << 4);
  }
}
