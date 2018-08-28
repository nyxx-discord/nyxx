part of nyxx;

abstract class ISend {
  Future<Message> send(
      {Object content: "",
      EmbedBuilder embed,
      bool tts: false,
      bool disableEveryone});

  Future<Message> sendFile(List<File> files,
      {String content = "", EmbedBuilder embed});
}

String expandAttachment(String filename) => "attachment://$filename";
