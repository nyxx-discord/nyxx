import '../objects.dart';

class MessageOptions {
  /// Whether or not to send the message using TTS.
  bool tts = false;

  /// A nonce for the message.
  String nonce;

  /// Whether or not to disable @everyone and @here mentions for the message.
  bool disableEveryone = false;
}
