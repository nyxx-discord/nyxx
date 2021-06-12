part of nyxx_lavalink;

/// Player update event dispatched by lavalink
class PlayerUpdate extends BaseEvent {
  /// State of the current player
  PlayerUpdateState state;

  /// Guild id where player comes from
  Snowflake guildId;

  PlayerUpdate._fromJson(Nyxx client, Map<String, dynamic> json)
  : guildId = Snowflake(json["guildId"]),
    state = PlayerUpdateState(json["state"]["time"] as int, json["state"]["position"] as int),
    super(client);
}

class PlayerUpdateState {
  int time;
  int position;

  PlayerUpdateState(this.time, this.position);
}