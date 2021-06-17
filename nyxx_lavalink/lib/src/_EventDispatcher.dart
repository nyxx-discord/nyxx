part of nyxx_lavalink;

class _EventDispatcher {
  _Cluster cluster;

  final StreamController<StatsEvent> onStatsReceived = StreamController.broadcast();
  final StreamController<PlayerUpdate> onPlayerUpdate = StreamController.broadcast();
  final StreamController<TrackStart> onTrackStart = StreamController.broadcast();
  final StreamController<TrackEnd> onTrackEnd = StreamController.broadcast();
  final StreamController<WebSocketClosed> onWebSocketClosed = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> onRawEvent = StreamController.broadcast();

  void dispatchEvent(Map<String, dynamic> json) {
    final node = cluster._nodes[json["nodeId"]];

    if(node == null) return;

    cluster._logger.log(
        logging.Level.FINE,
        "[Node ${json["nodeId"]}] Dispatching ${json["event"]}"
    );

    this.onRawEvent.add(json);

    switch(json["event"]) {
      case "TrackStart":
        this.onTrackStart.add(
            TrackStart._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;

      case "TrackEnd": {
          final trackEnd = TrackEnd._fromJson(cluster._client, node,
              json["data"] as Map<String, dynamic>
          );

          this.onTrackEnd.add(
              trackEnd
          );

          node._handleTrackEnd(trackEnd);
        }
        break;

      case "WebSocketClosed":
        this.onWebSocketClosed.add(
            WebSocketClosed._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;


      case "Stats": {
        final stats = StatsEvent._fromJson(cluster._client, node,
            json["data"] as Map<String, dynamic>
        );

        // Put the stats into the node
        node.stats = stats;

        this.onStatsReceived.add(stats);
        }
        break;


      case "PlayerUpdate":
        this.onPlayerUpdate.add(
            PlayerUpdate._fromJson(cluster._client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;
    }
  }

  _EventDispatcher(this.cluster) {
    cluster.onStatsReceived = this.onStatsReceived.stream;
    cluster.onPlayerUpdate = this.onPlayerUpdate.stream;
    cluster.onTrackStart = this.onTrackStart.stream;
    cluster.onTrackEnd = this.onTrackEnd.stream;
    cluster.onWebSocketClosed = this.onWebSocketClosed.stream;
    cluster.onRawEvent = this.onRawEvent.stream;
  }
}
