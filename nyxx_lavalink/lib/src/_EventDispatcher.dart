part of nyxx_lavalink;

class _EventDispatcher {
  Cluster cluster;

  final StreamController<Stats> onStatsReceived = StreamController.broadcast();
  final StreamController<PlayerUpdate> onPlayerUpdate = StreamController.broadcast();
  final StreamController<TrackStart> onTrackStart = StreamController.broadcast();
  final StreamController<TrackEnd> onTrackEnd = StreamController.broadcast();
  final StreamController<WebSocketClosed> onWebSocketClosed = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> onRawEvent = StreamController.broadcast();

  Future<void> dispatchEvent(Map<String, dynamic> json) async {
    final node = cluster.nodes[json["nodeId"]];

    if(node == null) return;

    cluster._logger.log(
        logging.Level.FINE,
        "[Node ${json["nodeId"]}] Dispatching ${json["event"]}"
    );

    this.onRawEvent.add(json);

    switch(json["event"]) {
      case "TrackStart":
        this.onTrackStart.add(
            TrackStart._fromJson(cluster.client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;

      case "TrackEnd": {
          final trackEnd = TrackEnd._fromJson(cluster.client, node,
              json["data"] as Map<String, dynamic>
          );

          this.onTrackEnd.add(
              trackEnd
          );

          await node._handleTrackEnd(trackEnd);
        }
        break;

      case "WebSocketClosed":
        this.onWebSocketClosed.add(
            WebSocketClosed._fromJson(cluster.client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;


      case "Stats":
        this.onStatsReceived.add(
            Stats._fromJson(cluster.client, node,
                json["data"] as Map<String, dynamic>
            )
        );
        break;


      case "PlayerUpdate":
        this.onPlayerUpdate.add(
            PlayerUpdate._fromJson(cluster.client, node,
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