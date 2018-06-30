part of nyxx;

/// Provides basic abstraction for sending messages. 
abstract class MessageChannel {

  /// Sends new message to channel
  Future<Message> send(
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone});
}
