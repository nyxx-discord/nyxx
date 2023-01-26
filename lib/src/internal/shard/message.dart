class ShardMessage<T> {
  final T type;
  final dynamic data;

  final int seq;

  const ShardMessage(this.type, {required this.seq, this.data});
}

enum ShardToManager {
  /// Sent when the shard receives a payload from Discord.
  ///
  /// Data payload includes:
  /// - `data`: dynamic
  ///     The uncompressed and JSON-decoded data received
  received,

  /// Sent when the shard encounters an error.
  ///
  /// Errors reported include state errors and errors that occurred during the initial connection.
  /// Any error causing the connection to close will send [disconnected] with a non-normal close code.
  ///
  /// Data payload includes:
  /// - `message`: String
  ///     The message associated with the error
  /// - `shouldReconnect`: bool?
  ///     Whether the shard should attempt to reconnect following this error
  error,

  /// Sent when the shard is connected
  connected,

  /// Send when the shard successfully reconnects
  reconnected,

  /// Send when the shard is disconnected
  ///
  /// Data payload includes:
  /// - `closeCode`: int
  ///     The code associated with the websocket disconnection
  /// - `closeReason`: String?
  ///     The message associated with the disconnection
  disconnected,

  /// Send when the shard is disposed
  disposed,
}

enum ManagerToShard {
  /// Sent when the shard should send a payload to Discord
  ///
  /// Data payload includes:
  /// - `opCode`: int
  ///     The opcode of the payload to send
  /// - `d`: dynamic
  ///     The data to send in the payload
  send,

  /// Sent to request the shard to connect and start dispatching events back to the manager
  ///
  /// Data payload includes:
  /// - `gatewayHost`: String
  ///     The URL on which to connect to the gateway
  /// - `useCompression`: bool
  ///     Whether to use compression on this gateway connection
  /// - `encoding`: Encoding
  ///     The encoding type du use to receive/send payloads
  connect,

  /// Sent to request the shard to reconnect, closing the current connection if any.
  ///
  /// This will disconnect with a non-normal disconnect code.
  ///
  /// Data payload includes:
  /// - `gatewayHost`: String
  ///     The URL on which to connect to the gateway
  /// - `useCompression`: bool
  ///     Whether to use compression on this gateway connection
  reconnect,

  /// Send to request the shard to disconnect, with a normal disconnection code.
  disconnect,

  /// Sent to dispose the shard
  dispose,
}
