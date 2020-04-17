part of nyxx;

/// The WS manager for the client.
class _WS {
  Nyxx _client;

  /// The base websocket URL.
  late String gateway;

  late int remaining;
  late DateTime resetAt;

  final Logger logger = Logger("Client");

  /// Makes a new WS manager.
  _WS(this._client) {
    _client._http._execute(JsonRequest._new("/gateway/bot")).then((httpResponse) {
      if(httpResponse is HttpResponseError) {
        this.logger.severe("Cannot get gateway url");
        exit(1);
      }
      
      var response = httpResponse as HttpResponseSuccess;
      
      this.gateway = response.jsonBody['url'] as String;

      this.remaining = response.jsonBody['session_start_limit']['remaining'] as int;
      this.resetAt = DateTime.now().add(Duration(
          milliseconds: response.jsonBody['session_start_limit']['reset_after'] as int));
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
  }

  void connectShard(int index) {
    _client.shard._connect(false, true);
  }

  Future<void> propagateReady() async {
    _client.ready = true;

    var httpResponse = await _client._http._execute(JsonRequest._new("/oauth2/applications/@me"));

    if(httpResponse is HttpResponseError) {
      this.logger.severe("Cannot get bot identity");
      exit(1);
    }

    var response = httpResponse as HttpResponseSuccess;

    _client.app = ClientOAuth2Application._new(
        response.jsonBody as Map<String, dynamic>, _client);

    _client._events.onReady.add(ReadyEvent._new(_client));
    logger.info("Connected and ready! Logged as `${_client.self.tag}`");
  }
}
