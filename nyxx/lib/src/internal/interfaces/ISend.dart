part of nyxx;

/// Marks entity to which message can be sent
// ignore: one_member_abstracts
abstract class ISend {
  /// Sends message
  Future<Message?> sendMessage({
    dynamic content,
    EmbedBuilder? embed,
    List<AttachmentBuilder>? files,
    bool? tts,
    AllowedMentions? allowedMentions,
    MessageBuilder? builder
  });
}
