part of nyxx.lavalink;

/// Stats object which is emitted every one minute
class Stats {
  /// Number of players connected
  int players;

  /// Number of currenlty playing players
  int playingPlayers;

  /// Lavalink uptime
  int uptime;

  /// Smout of free system memory
  int memoryFree;

  ///Memory used by lavalink
  int memoryUsed;

  /// Total amount of memory allocated for Lavalink
  int memoryAllocated;

  /// Amout of memory which can be reserved
  int memoryReservable;

  /// Number of machine cpu cores
  int cpuCores;

  /// Whole system load
  double systemLoad;

  /// Load of lavalink
  double lavalinkLoad;

  /// Average number of frames sent to server in minute
  int avgFramesSent;

  /// Average number of frames nulled in minute
  int avgFramesNull;

  /// Average number of frames deficit in minute
  int avgFramesDeficit;

  /// Raw object returned by websocket
  Map<String, dynamic> raw;

  Stats._new(this.raw) {
    players = raw['players'] as int;
    playingPlayers = raw['playingPlayers'] as int;
    memoryFree = raw['memory']['free'] as int;
    memoryUsed = raw['memory']['used'] as int;
    memoryAllocated = raw['memory']['allocated'] as int;
    memoryReservable = raw['memory']['reservable'] as int;
    cpuCores = raw['cpu']['cores'] as int;
    systemLoad = raw['cpu']['systemLoad'] as double;
    lavalinkLoad = raw['cpu']['reservable'] as double;

    if (raw['frames'] != null) {
      avgFramesSent = raw['frames']['sent'] as int;
      avgFramesNull = raw['frames']['nulled'] as int;
      avgFramesDeficit = raw['frames']['deficit'] as int;
    }
  }
}
