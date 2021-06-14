part of nyxx_lavalink;

/// Stats update event dispatched by lavalink
class Stats extends BaseEvent {
  /// Number of playing players
  int playingPlayers;
  ///Memory usage stats
  Memory memory;
  /// Frame sending stats
  FrameStats? frameStats;
  /// Total amount of players
  int players;
  /// Cpu usage stats
  Cpu cpu;
  /// Server uptime
  int uptime;

  Stats._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
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
  int sent;
  /// Deficit frames
  int deficit;
  /// Nulled frames
  int nulled;

  FrameStats._fromJson(Map<String, dynamic> json)
  : sent = json["sent"] as int,
    deficit = json["deficit"] as int,
    nulled = json["nulled"] as int;
}

/// Cpu usage stats
class Cpu {
  /// Amount of available cores on the cpu
  int cores;
  /// The total load of the machine where lavalink is running on
  num systemLoad;
  /// The total load of lavalink server
  num lavalinkLoad;

  Cpu._fromJson(Map<String, dynamic> json)
  : cores = json["cores"] as int,
    systemLoad = json["systemLoad"] as num,
    lavalinkLoad = json["lavalinkLoad"] as num;
}

/// Memory usage stats
class Memory {
  /// Reservable memory
  int reservable;
  /// Used memory
  int used;
  /// Free/unused memory
  int free;
  /// Total allocated memory
  int allocated;

  Memory._fromJson(Map<String, dynamic> json)
  : reservable = json["reservable"] as int,
    used = json["used"] as int,
    free = json["free"] as int,
    allocated = json["allocated"] as int;
}