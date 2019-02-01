part of nyxx;

/// The WS manager for the client.
class _WS {
  Nyxx _client;

  /// The base websocket URL.
  String gateway;

  int remaining;
  DateTime resetAt;

  final Logger logger = Logger("Client");

  /// Makes a new WS manager.
  _WS(this._client) {
    _client._http._headers['Authorization'] = "Bot ${_client._token}";
    _client._http.send("GET", "/gateway/bot").then((HttpResponse r) {
      this.gateway = r.body['url'] as String;

      this.remaining = r.body['session_start_limit']['remaining'] as int;
      this.resetAt = DateTime.now().add(Duration(
          milliseconds: r.body['session_start_limit']['reset_after'] as int));
      logger.info(
          "Remaining ${this.remaining} connections starts. Limit will reset at ${this.resetAt}");

      checkForConnections();

      setupShard(_client._options.shardIndex);
      this.connectShard(0);
    });
  }

  void checkForConnections() {
    if (this.remaining < 50) logger.warning("50 connection starts left.");

    if (this.remaining < 10) {
      logger
          .severe("Exiting to prevent API abuse. 10 connections starts left.");
      exit(1);
    }
  }

  void setupShard(int shardId) {
    Shard shard = Shard._new(this, shardId);
    _client.shard = shard;

    shard.onReady.listen((Shard s) {
      if (!_client.ready) {
        testReady();
      }
    });
  }

  void connectShard(int index) {
    _client.shard._connect(false, true);
  }

  void testReady() {
    bool match1() {
      for (var o in _client.guilds.values) {
        if (_client._options.forceFetchMembers &&
            o.members.count != o.memberCount) {
          return false;
        }
      }

      return true;
    }

    bool match2() {
      if (!_client.shard.ready) {
        return false;
      }

      return true;
    }

    if (match1() && match2()) {
      _client.ready = true;
      _client._startTime = DateTime.now();

      _client._http.send("GET", "/oauth2/applications/@me").then((response) {
        _client.app = ClientOAuth2Application._new(
            response.body as Map<String, dynamic>, _client);

        _client._events.onReady.add(ReadyEvent._new(_client));
        logger.info("Connected and ready! Logged as `${_client.self.tag}`");
      });
    } else {
      //logger.severe("Cannot setup bot properly.");
      //exit(1);
    }
  }
}
