part of discord;

/// The WS manager for the client.
class _WS {
  int shardCount;

  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  /// Makes a new WS manager.
  _WS(this.client) {
    this.client._http.headers['Authorization'] = "Bot ${client._token}";
    this.client._http.get("/gateway/bot", true).then((_HttpResponse r) {
      this.gateway = r.json['url'];
      this.shardCount = r.json['shards'];
      if (this.client._options.shardCount == 1 &&
          this.client._options.shardIds == const [0]) {
        for (int i = 0; i < shardCount; i++) {
          setupShard(i);
        }
      } else {
        for (int shardId in this.client._options.shardIds) {
          setupShard(shardId);
        }
      }
      this.connectShard(0);
    }).catchError((err) {
      this.client._http.get('/gateway', true).then((_HttpResponse r) {
        this.gateway = r.json['url'];
        for (int shardId in this.client._options.shardIds) {
          setupShard(shardId);
        }
        this.connectShard(0);
      });
    });
  }

  void setupShard(int shardId) {
    Shard shard = new Shard._new(this, shardId);
    this.client.shards.add(shard);

    shard.onReady.stream.listen((Shard s) {
      if (!client.ready) {
        bool match = true;
        client.guilds.forEach((Guild o) {
          if (o == null) match = false;
        });

        bool match2 = true;
        client.shards.forEach((Shard s) {
          if (!s.ready) match = false;
        });

        if (match && match2) {
          client.ready = true;
          if (client.user.bot) {
            client._http
                .get('/oauth2/applications/@me', true)
                .then((_HttpResponse r) {
              client.app = new ClientOAuth2Application._new(client, r.json);
              new ReadyEvent._new(client);
            });
          } else {
            new ReadyEvent._new(client);
          }
        }
      }
    });
  }

  Future<Null> close() async {
    this.client.shards.forEach((Shard shard) async {
      await shard._socket.close();
    });
    return null;
  }

  void connectShard(int index) {
    this.client.shards.list[index]._connect();
    if (index + 1 != this.client._options.shardIds.length)
      new Timer(new Duration(seconds: 6), () => connectShard(index + 1));
  }
}
