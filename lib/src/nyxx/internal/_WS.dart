part of nyxx;

/// The WS manager for the client.
class _WS {
  bool bot = false;

  /// The base websocket URL.
  String gateway;

  /// The client that the WS manager belongs to.
  Client client;

  final Logger logger = new Logger("Client");

  /// Makes a new WS manager.
  _WS(this.client) {
    this.client.http.headers['Authorization'] = "Bot ${client._token}";
    this
        .client
        .http
        .send("GET", "/gateway/bot", beforeReady: true)
        .then((HttpResponse r) {
      this.bot = true;
      this.gateway = r.body['url'] as String;
      if (this.client._options.shardCount == 1 &&
          this.client._options.shardIds == const [0]) {
        this.client._options.shardIds = [];
        this.client._options.shardCount = r.body['shards'] as int;
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
      this
          .client
          .http
          .send('GET', '/gateway', beforeReady: true)
          .then((HttpResponse r) {
        this.gateway = r.body['url'] as String;
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

    shard.onReady.listen((Shard s) {
      if (!client.ready) {
        testReady();
      }
    });
  }

  void connectShard(int index) {
    this.client.shards.values.toList()[index]._connect(true, true);
    if (index + 1 != this.client._options.shardIds.length)
      new Timer(new Duration(seconds: 6), () => connectShard(index + 1));
  }

  void testReady() {
    bool match = true;
    client.guilds.forEach((Snowflake id, Guild o) {
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

      this.client.http.send("GET", "/oauth2/applications/@me").then((response) {
        this.client.app = new ClientOAuth2Application._new(this.client, response.body as Map<String, dynamic>);

        new ReadyEvent._new(client);
        logger.info("Connected and ready!");
      });
    }
  }
}
