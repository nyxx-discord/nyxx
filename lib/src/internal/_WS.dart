part of discord;

/// The WS manager for the client.
class _WS {
  bool bot = false;

  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  /// Makes a new WS manager.
  _WS(this.client) {
    this.client._http.headers['Authorization'] = "Bot ${client._token}";
    this.client._http.get("/gateway/bot", true).then((_HttpResponse r) {
      this.bot = true;
      this.gateway = r.json['url'];
      if (this.client._options.shardCount == 1 &&
          this.client._options.shardIds == const [0]) {
        this.client._options.shardIds = [];
        this.client._options.shardCount = r.json['shards'];
        for (int i = 0; i < client._options.shardCount; i++) {
          this.client._options.shardIds.add(i);
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
    this.client.shards[shard.id] = shard;

    shard.onReady.stream.listen((Shard s) {
      if (!client.ready) {
        testReady();
      }
    });
  }

  Future<Null> close() async {
    this.client.shards.forEach((int id, Shard shard) async {
      await shard._socket.close();
    });
    return null;
  }

  void connectShard(int index) {
    this.client.shards.values.toList()[index]._connect();
    if (index + 1 != this.client._options.shardIds.length)
      new Timer(new Duration(seconds: 6), () => connectShard(index + 1));
  }

  void testReady() {
    bool match = true;
    client.guilds.forEach((String id, Guild o) {
      if (client._options.forceFetchMembers) {
        if (o == null || o.members.length != o.memberCount) match = false;
      } else {
        if (o == null) match = false;
      }
    });

    bool match2 = true;
    this.client.shards.forEach((int id, Shard s) {
      if (!s.ready) match = false;
    });

    if (match && match2) {
      client.ready = true;
      client._startTime = new DateTime.now();
      if (client.user.bot) {
        client._http
            .get('/oauth2/applications/@me', true)
            .then((_HttpResponse r) {
          client.app = new ClientOAuth2Application._new(
              client, r.json as Map<String, dynamic>);
          new ReadyEvent._new(client);
        });
      } else {
        new ReadyEvent._new(client);
      }
    }
  }
}
