part of nyxx;

/// The WS manager for the client.
class _WS {
  final Nyxx _client;

  /// The base websocket URL.
  late String gateway;

  late int remaining;
  late DateTime resetAt;
  late int recommendedShardsNum;

  final Logger _logger = Logger("Client");

  /// Makes a new WS manager.
  _WS(this._client) {
    _client._http._execute(BasicRequest._new("/gateway/bot")).then((httpResponse) {
      if (httpResponse is HttpResponseError) {
        this._logger.severe("Cannot get gateway url");
        exit(1);
      }

      final response = httpResponse as HttpResponseSuccess;

      this.gateway = response.jsonBody["url"] as String;
      this.remaining = response.jsonBody["session_start_limit"]["remaining"] as int;
      this.resetAt = DateTime.now().add(Duration(milliseconds: response.jsonBody["session_start_limit"]["reset_after"] as int));
      this.recommendedShardsNum = response.jsonBody["shards"] as int;

      checkForConnections();

      this._client.shardManager = ShardManager(this, this._client._options.shardCount != null ? this._client._options.shardCount! : this.recommendedShardsNum);
    });
  }

  void checkForConnections() {
    _logger.info("Remaining ${this.remaining} connections starts. Limit will reset at ${this.resetAt}");

    if (this.remaining < 50) {
      _logger.warning("50 connection starts left.");
    }

    if (this.remaining < 10) {
      _logger.severe("Exiting to prevent API abuse. 10 connections starts left.");
      exit(1);
    }
  }

  Future<void> propagateReady() async {
    if(_client.ready) {
      return;
    }

    _client.ready = true;

    final httpResponse = await _client._http._execute(BasicRequest._new("/oauth2/applications/@me"));

    if (httpResponse is HttpResponseError) {
      this._logger.severe("Cannot get bot identity");
      exit(1);
    }

    final response = httpResponse as HttpResponseSuccess;

    _client.app = ClientOAuth2Application._new(response.jsonBody as Map<String, dynamic>, _client);

    _client._events.onReady.add(ReadyEvent._new(_client));
    _logger.info("Connected and ready! Logged as `${_client.self.tag}`");
  }
}
