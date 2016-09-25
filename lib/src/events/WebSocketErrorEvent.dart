import '../../objects.dart';
import '../client.dart';

/// Sent when the websocket encounters an error (but certian errors will throw
/// an exception).
class WebSocketErrorEvent {
  /// The error code.
  int errorCode;

  /// Constructs a new [WebSocketErrorEvent].
  WebSocketErrorEvent(Client client, int code) {
    this.errorCode = code;
    client.emit("webSocketError", this);
  }
}
