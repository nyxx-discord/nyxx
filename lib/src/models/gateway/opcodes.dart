enum Opcodes {
  dispatch._(0),
  heartbeat._(1),
  identify._(2),
  presence._(3),
  voiceStateUpdate._(4),
  resume._(6),
  reconnect._(7),
  requestGuildMembers._(8),
  invalidSession._(9),
  helloReceive._(10),
  heartbeatAckReceive._(11);

  final int value;

  const Opcodes._(this.value);
}
