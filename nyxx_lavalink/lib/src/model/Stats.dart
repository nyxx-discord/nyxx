part of nyxx_lavalink;

/// Stats update event dispatched by lavalink
class StatsEvent extends BaseEvent {
  /// Number of playing players
  final int playingPlayers;
  ///Memory usage stats
  final Memory memory;
  /// Frame sending stats
  final FrameStats? frameStats;
  /// Total amount of players
  final int players;
  /// Cpu usage stats
  final Cpu cpu;
  /// Server uptime
  final int uptime;

  StatsEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : playingPlayers = json["playingPlayers"] as int,
    players = json["players"] as int,
    uptime = json["uptime"] as int,
    memory = Memory._fromJson(json["memory"] as Map<String, dynamic>),
    frameStats = json["frameStats"] == null ? null : FrameStats._fromJson(json["frameStats"] as Map<String, dynamic>),
    cpu = Cpu._fromJson(json["cpu"] as Map<String, dynamic>),
    super(client, node);
}

/// Stats about frame sending to discord
class FrameStats {
  /// Sent frames
  final int sent;
  /// Deficit frames
  final int deficit;
  /// Nulled frames
  final int nulled;

  FrameStats._fromJson(Map<String, dynamic> json)
  : sent = json["sent"] as int,
    deficit = json["deficit"] as int,
    nulled = json["nulled"] as int;
}

/// Cpu usage stats
class Cpu {
  /// Amount of available cores on the cpu
  final int cores;
  /// The total load of the machine where lavalink is running on
  final num systemLoad;
  /// The total load of lavalink server
  final num lavalinkLoad;

  Cpu._fromJson(Map<String, dynamic> json)
  : cores = json["cores"] as int,
    systemLoad = json["systemLoad"] as num,
    lavalinkLoad = json["lavalinkLoad"] as num;
}

/// Memory usage stats
class Memory {
  /// Reservable memory
  final int reservable;
  /// Used memory
  final int used;
  /// Free/unused memory
  final int free;
  /// Total allocated memory
  final int allocated;

  Memory._fromJson(Map<String, dynamic> json)
  : reservable = json["reservable"] as int,
    used = json["used"] as int,
    free = json["free"] as int,
    allocated = json["allocated"] as int;
}
