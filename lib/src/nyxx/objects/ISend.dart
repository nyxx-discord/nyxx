part of nyxx;

/// Marks entity to which message can be sent
abstract class ISend {
  Future<Message> send(
      {Object content = "",
      List<File> files,
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone,
      MessageBuilder builder});
}

/// Generate Attachment string for [filename]
String attach(String filename) => "attachment://$filename";

// Sanitized message from @everyone and @here
String _sanitizeMessage(Object content, bool disableEveryone, Nyxx client) {
  var msg = content.toString();
  if (content != null &&
      ((disableEveryone != null && disableEveryone) ||
          (disableEveryone == null && client._options.disableEveryone))) {
    return msg
        .replaceAll("@everyone", "@\u200Beveryone")
        .replaceAll("@here", "@\u200Bhere");
  } else
    return msg;
}
