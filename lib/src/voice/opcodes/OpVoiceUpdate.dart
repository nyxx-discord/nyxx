part of nyxx.voice;

class OpVoiceUpdate {
  String op = "voiceUpdate";
  String guildId;
  String sessionId;
  dynamic event;

  OpVoiceUpdate(this.guildId, this.sessionId, this.event);

  dynamic build() {
    return {
      "op": op,
      "guildId": guildId,
      "sessionId": sessionId,
      "event": event['d']
    };
  }
}