part of nyxx_lavalink;

class _EventDispatcher implements Disposable {
  final Cluster cluster;

  final StreamController<StatsEvent> onStatsReceived = StreamController.broadcast();
  final StreamController<PlayerUpdateEvent> onPlayerUpdate = StreamController.broadcast();
  final StreamController<TrackStartEvent> onTrackStart = StreamController.broadcast();
  final StreamController<TrackEndEvent> onTrackEnd = StreamController.broadcast();
  final StreamController<WebSocketClosedEvent> onWebSocketClosed = StreamController.broadcast();

  _EventDispatcher(this.cluster) {
    cluster.onStatsReceived = this.onStatsReceived.stream;
    cluster.onPlayerUpdate = this.onPlayerUpdate.stream;
    cluster.onTrackStart = this.onTrackStart.stream;
    cluster.onTrackEnd = this.onTrackEnd.stream;
    cluster.onWebSocketClosed = this.onWebSocketClosed.stream;
  }

  void dispatchEvent(Map<String, dynamic> json) {
    final node = cluster._nodes[json["nodeId"]];

    if(node == null) {
      return;
    }

    cluster._logger.fine("[Node ${json["nodeId"]}] Dispatching ${json["event"]}");

    switch(json["event"]) {
      case "TrackStartEvent":
        this.onTrackStart.add(
            TrackStartEvent._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;

      case "TrackEndEvent": {
          final trackEnd = TrackEndEvent._fromJson(cluster._client, node,
              json["data"] as Map<String, dynamic>
          );

          this.onTrackEnd.add(
              trackEnd
          );

          node._handleTrackEnd(trackEnd);
        }
        break;

      case "WebSocketClosedEvent":
        this.onWebSocketClosed.add(
            WebSocketClosedEvent._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;

      case "stats": {
        final stats = StatsEvent._fromJson(cluster._client, node,
            json["data"] as Map<String, dynamic>
        );

        // Put the stats into the node
        node._stats = stats;

        this.onStatsReceived.add(stats);
        }
        break;

      case "playerUpdate":
        this.onPlayerUpdate.add(
            PlayerUpdateEvent._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;
    }
  }

  @override
  Future<void> dispose() async {
    await this.onStatsReceived.close();
    await this.onPlayerUpdate.close();
    await this.onTrackStart.close();
    await this.onTrackEnd.close();
    await this.onWebSocketClosed.close();
  }
}
