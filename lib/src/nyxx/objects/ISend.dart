part of nyxx;

abstract class ISend {
  Future<Message> send(
      {Object content: "",
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone});
}
