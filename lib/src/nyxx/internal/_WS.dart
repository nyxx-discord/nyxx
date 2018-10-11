part of nyxx;

/// The WS manager for the client.
class _WS {
  /// The base websocket URL.
  String gateway;

  final Logger logger = Logger("Client");

  /// Makes a new WS manager.
  _WS() {
    _client.http._headers['Authorization'] = "Bot ${client._token}";
    _client.http
        .send("GET", "/gateway/bot", beforeReady: true)
        .then((HttpResponse r) {
      this.gateway = r.body['url'] as String;
      if (client._options.autoShard) {
        _client._options.shardIds = [];
        _client._options.shardCount = r.body['shards'] as int;
        for (int i = 0; i < client._options.shardCount; i++) {
          //_client._options.shardIds.add(i);
          setupShard(i);
        }
      } else {
        for (int shardId in _client._options.shardIds) {
          setupShard(shardId);
        }
      }
      this.connectShard(0);
    });
  }

  void setupShard(int shardId) {
    Shard shard = Shard._new(this, shardId);
    _client.shards[shard.id] = shard;

    shard.onReady.listen((Shard s) {
      if (!client.ready) {
        testReady();
      }
    });
  }

  void connectShard(int index) {
    _client.shards.values.toList()[index]._connect(false, true);
    if (index + 1 != _client._options.shardIds.length)
      Timer(Duration(seconds: 6), () => connectShard(index + 1));
  }

  void testReady() {
    bool match = true;
    for (var o in _client.guilds.values) {
      if (o == null) {
        match = false;
        break;
      }

      if (client._options.forceFetchMembers)
        if (o.members.count != o.memberCount) {
          match = false;
          break;
        }
    }

    bool match2 = true;
    for (var shard in _client.shards.values) {
      if (!shard.ready) {
        match2 = false;
        break;
      }
    }

    if (match && match2) {
      client.ready = true;
      client._startTime = DateTime.now();

      _client.http.send("GET", "/oauth2/applications/@me").then((response) {
        _client.app =
            ClientOAuth2Application._new(response.body as Map<String, dynamic>);

        ReadyEvent._new();
        logger.info("Connected and ready!");
      });
    }
  }
}
