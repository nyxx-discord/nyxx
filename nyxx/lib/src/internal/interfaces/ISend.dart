part of nyxx;

/// Marks entity to which message can be sent
abstract class ISend {
  Nyxx get client;

  /// Sends message
  Future<Message> send(
      {dynamic content,
      List<AttachmentBuilder>? files,
      EmbedBuilder? embed,
      bool? tts,
      AllowedMentions? allowedMentions,
      MessageBuilder? builder});


  Map<String, dynamic> _initMessage(dynamic content, EmbedBuilder? embed, AllowedMentions? allowedMentions) {
    if(content == null && embed == null) {
      throw new Exception("When sending message both content and embed cannot be null");
    }
    
    if(allowedMentions == null) {
      allowedMentions = client._options.allowedMentions;
    }

    return <String, dynamic>{
      if(content != null) "content": content.toString(),
      if(embed != null) "embed" : embed._build(),
      if (allowedMentions != null) "allowed_mentions" : allowedMentions._build()
    };
  }
}