/// The options for message sending.
class MessageOptions {
  /// Whether or not to send the message using TTS.
  bool tts;

  /// A nonce for the message.
  String nonce;

  /// Whether or not to disable @everyone and @here mentions for the message.
  bool disableEveryone;

  /// Makes a new `ClientOptions` object.
  MessageOptions({this.tts: false, this.nonce, this.disableEveryone});
}
