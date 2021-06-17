part of nyxx_lavalink;

/// Stats update event dispatched by lavalink
class StatsEvent extends BaseEvent {
  /// Number of playing players
  late final int playingPlayers;
  ///Memory usage stats
  late final MemoryStats memory;
  /// Frame sending stats
  late final FrameStats? frameStats;
  /// Total amount of players
  late final int players;
  /// Cpu usage stats
  late final CpuStats cpu;
  /// Server uptime
  late final int uptime;

  StatsEvent._fromJson(Nyxx client, Node node, Map<String, dynamic> json)
  : super(client, node)
  {
    this.playingPlayers = json["playingPlayers"] as int;
    this.players = json["players"] as int;
    this.uptime = json["uptime"] as int;
    this.memory = MemoryStats._fromJson(json["memory"] as Map<String, dynamic>);
    this.frameStats = json["frameStats"] == null ? null : FrameStats._fromJson(json["frameStats"] as Map<String, dynamic>);
    this.cpu = CpuStats._fromJson(json["cpu"] as Map<String, dynamic>);
  }
}

/// Stats about frame sending to discord
class FrameStats {
  /// Sent frames
  late final int sent;
  /// Deficit frames
  late final int deficit;
  /// Nulled frames
  late final int nulled;

  FrameStats._fromJson(Map<String, dynamic> json) {
    this.sent = json["sent"] as int;
    this.deficit = json["deficit"] as int;
    this.nulled = json["nulled"] as int;
  }
}

/// Cpu usage stats
class CpuStats {
  /// Amount of available cores on the cpu
  late final int cores;
  /// The total load of the machine where lavalink is running on
  late final num systemLoad;
  /// The total load of lavalink server
  late final num lavalinkLoad;

  CpuStats._fromJson(Map<String, dynamic> json) {
    this.cores = json["cores"] as int;
    this.systemLoad = json["systemLoad"] as num;
    this.lavalinkLoad = json["lavalinkLoad"] as num;
  }
}

/// Memory usage stats
class MemoryStats {
  /// Reservable memory
  late final int reservable;
  /// Used memory
  late final int used;
  /// Free/unused memory
  late final int free;
  /// Total allocated memory
  late final int allocated;

  MemoryStats._fromJson(Map<String, dynamic> json) {
    this.reservable = json["reservable"] as int;
    this.used = json["used"] as int;
    this.free = json["free"] as int;
    this.allocated = json["allocated"] as int;
  }
}
