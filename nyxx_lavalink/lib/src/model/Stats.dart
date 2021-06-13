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

  /// Construct a new instance with provided data
  FrameStats(this.sent, this.deficit, this.nulled);

  static FrameStats _fromJson(Map<String, dynamic> json) => FrameStats(json["sent"] as int, json["deficit"] as int, json["nulled"] as int);
}

/// Cpu usage stats
class Cpu {
  /// Amount of available cores on the cpu
  int cores;
  /// The total load of the machine where lavalink is running on
  num systemLoad;
  /// The total load of lavalink server
  num lavalinkLoad;

  /// Construct a new instance with provided data
  Cpu(this.cores, this.systemLoad, this.lavalinkLoad);

  static Cpu _fromJson(Map<String, dynamic> json) => Cpu(json["cores"] as int, json["systemLoad"] as num, json["lavalinkLoad"] as num);
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

  /// Construct a new instance with provided data
  Memory(this.reservable, this.used, this.free, this.allocated);

  static Memory _fromJson(Map<String, dynamic> json) => Memory(json["reservable"] as int, json["used"] as int, json["free"] as int, json["allocated"] as int);
}