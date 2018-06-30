part of nyxx;

abstract class MessageChannel {
  Future<Message> send(
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone});
}
