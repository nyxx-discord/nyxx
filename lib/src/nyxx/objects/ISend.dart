part of nyxx;

abstract class ISend {
  Future<Message> send(
      {Object content = "",
      EmbedBuilder embed,
      bool tts = false,
      bool disableEveryone});

  Future<Message> sendFile(List<File> files,
      {String content = "", EmbedBuilder embed, bool disableEveryone});
}

String expandAttachment(String filename) => "attachment://$filename";

String _sanitizeMessage(Object content, bool disableEveryone, Client client) {
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
