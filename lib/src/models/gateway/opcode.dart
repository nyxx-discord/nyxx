/// Opcodes sent or received over the Gateway.
enum Opcode {
  /// An event is dispatched to the client.
  dispatch._(0),

  /// Sent when heartbeating or received when requesting a heartbeat.
  heartbeat._(1),

  /// Sent when opening a Gateway session.
  identify._(2),

  /// Sent when updating the client's presence.
  presenceUpdate._(3),

  /// Sent when updating the client's voice state.
  voiceStateUpdate._(4),

  /// Send when resuming a Gateway session.
  resume._(6),

  /// Received when the client should reconnect.
  reconnect._(7),

  /// Sent to request guild members.
  requestGuildMembers._(8),

  /// Received when the client's session is invalid.
  invalidSession._(9),

  /// Received when the connection to the Gateway is opened.
  hello._(10),

  /// Received when the server receives the client's heartbeat.
  heartbeatAck._(11);

  /// The value of this [Opcode].
  final int value;

  const Opcode._(this.value);
}
