part of nyxx;

/// Extra features of the message
class MessageFlags {
  /// This message has been published to subscribed channels (via Channel Following)
  late final bool crossposted;

  /// This message originated from a message in another channel (via Channel Following)
  late final bool isCrosspost;

  /// Do not include any embeds when serializing this message
  late final bool supressEmbeds;

  /// The source message for this crosspost has been deleted (via Channel Following)
  late final bool sourceMessageDeleted;

  /// This message came from the urgent message system
  late final bool urgent;

  MessageFlags._new(int raw) {
    this.crossposted = PermissionsUtils.isApplied(raw, 1 << 0);
    this.isCrosspost = PermissionsUtils.isApplied(raw, 1 << 1);
    this.supressEmbeds = PermissionsUtils.isApplied(raw, 1 << 2);
    this.sourceMessageDeleted = PermissionsUtils.isApplied(raw, 1 << 3);
    this.urgent = PermissionsUtils.isApplied(raw, 1 << 4);
  }
}
