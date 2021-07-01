part of nyxx;

/// The WS manager for the client.
class _ConnectionManager {
  final Nyxx _client;

  /// The base websocket URL.
  late final String gateway;

  late final int remaining;
  late final DateTime resetAt;
  late final int recommendedShardsNum;
  late final int maxConcurrency;

  final Logger _logger = Logger("Client");

  int _shardsReady = 0;

  /// Makes a new WS manager.
  _ConnectionManager(this._client) {
    _client._httpEndpoints._getGatewayBot().then((httpResponse) {
      if (httpResponse is HttpResponseError) {
        this._logger.severe("Cannot get gateway url: [${httpResponse.errorCode}; ${httpResponse.errorMessage}]");
        exit(1);
      }

      final response = httpResponse as HttpResponseSuccess;

      this.gateway = response.jsonBody["url"] as String;
      this.remaining = response.jsonBody["session_start_limit"]["remaining"] as int;
      this.resetAt = DateTime.now().add(Duration(milliseconds: response.jsonBody["session_start_limit"]["reset_after"] as int));
      this.recommendedShardsNum = response.jsonBody["shards"] as int;
      this.maxConcurrency = response.jsonBody["session_start_limit"]["max_concurrency"] as int;

      this._logger.fine("Got gateway info: Url: [$gateway]; Recommended shard num: [$recommendedShardsNum]");

      checkForConnections();

      this._client.shardManager = ShardManager._new(this, this.maxConcurrency);
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
    this._shardsReady++;

    if(_client.ready || this._shardsReady < (_client._options.shardCount ?? 1)) {
      return;
    }

    final httpResponse = await _client._httpEndpoints._getMeApplication();

    if (httpResponse is HttpResponseError) {
      this._logger.shout("Cannot get bot identity: `${httpResponse.toString()}`");
      exit(1);
    }

    final response = httpResponse as HttpResponseSuccess;
    _client.app = ClientOAuth2Application._new(response.jsonBody as RawApiMap, _client);

    _client.ready = true;
    _client._events.onReady.add(ReadyEvent._new(_client));
    _logger.info("Connected and ready! Logged as `${_client.self.tag}`");
  }
}
