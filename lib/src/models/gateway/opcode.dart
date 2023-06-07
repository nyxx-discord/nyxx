enum Opcode {
  dispatch._(0),
  heartbeat._(1),
  identify._(2),
  presenceUpdate._(3),
  voiceStateUpdate._(4),
  resume._(6),
  reconnect._(7),
  requestGuildMembers._(8),
  invalidSession._(9),
  hello._(10),
  heartbeatAck._(11);

  final int value;

  const Opcode._(this.value);
}
