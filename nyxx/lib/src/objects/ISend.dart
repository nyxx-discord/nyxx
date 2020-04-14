part of nyxx;

/// Marks entity to which message can be sent
abstract class ISend {
  Nyxx get client;

  /// Sends message
  Future<Message?> send(
      {dynamic content,
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool? tts,
      AllowedMentions? allowedMentions,
      MessageBuilder? builder});


  Map<String, dynamic> _initMessage(dynamic content, AllowedMentions? allowedMentions) {
    if(allowedMentions == null) {
      allowedMentions = client._options.allowedMentions;
    }

    return <String, dynamic>{
      "content": content == null ? "" : content.toString(),
      if (allowedMentions != null) "allowed_mentions" : allowedMentions._build()
    };
  }
}