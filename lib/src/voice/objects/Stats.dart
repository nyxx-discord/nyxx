part of nyxx.voice;

class Stats {
  int players;
  int playingPlayers;
  int uptime;

  int memoryFree;
  int memoryUsed;

  int memoryAllocated;
  int memoryReservable;

  int cpuCores;
  double systemLoad;
  double lavalinkLoad;

  int avgFramesSent;
  int avgFramesNull;
  int avgFramesDeficic;

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

    if(raw['frames'] != null) {
      avgFramesSent = raw['frames']['sent'] as int;
      avgFramesNull = raw['frames']['nulled'] as int;
      avgFramesDeficic = raw['frames']['deficit'] as int;
    }
  }
}
