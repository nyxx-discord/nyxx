part of nyxx;

/// The WS manager for the client.
class _WS {
  Nyxx _client;

  /// The base websocket URL.
  String gateway;

  final Logger logger = Logger("Client");

  /// Makes a new WS manager.
  _WS(this._client) {
    _client._http._headers['Authorization'] = "Bot ${_client._token}";
    _client._http.send("GET", "/gateway/bot").then((HttpResponse r) {
      this.gateway = r.body['url'] as String;
      if (_client._options.autoShard) {
        _client._options._shardIds = [];
        _client._options.shardCount = r.body['shards'] as int;
        for (int i = 0; i < _client._options.shardCount; i++) {
          setupShard(i);
        }
      } else {
        for (int shardId in _client._options._shardIds) {
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
      if (!_client.ready) {
        testReady();
      }
    });
  }

  void connectShard(int index) {
    _client.shards.values.toList()[index]._connect(false, true);
    if (index + 1 != _client._options._shardIds.length)
      Timer(Duration(seconds: 6), () => connectShard(index + 1));
  }

  void testReady() {
    bool match = true;
    for (var o in _client.guilds.values) {
      if (o == null) {
        match = false;
        break;
      }

      if (_client._options.forceFetchMembers) if (o.members.count !=
          o.memberCount) {
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
      _client.ready = true;
      _client._startTime = DateTime.now();

      _client._http.send("GET", "/oauth2/applications/@me").then((response) {
        _client.app =
            ClientOAuth2Application._new(response.body as Map<String, dynamic>, _client);

        _client._events.onReady.add(ReadyEvent._new(_client));
        logger.info("Connected and ready!");
      });
    }
  }
}
