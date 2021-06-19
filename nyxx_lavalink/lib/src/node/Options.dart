part of nyxx_lavalink;

/// Class containing all node options needed to establish and mantain a connection
/// with lavalink server
class NodeOptions {
  /// Host where lavalink is running
  late final String host;
  /// Port used by lavalink rest & socket
  late final int port;
  /// Whether to use a tls connection or not
  late final bool ssl;
  /// Password to connect to the server
  late final String password;
  /// Shards the bot is operating on
  late final int shards;
  /// Max connect attempts before shutting down a node
  late final int maxConnectAttempts;
  /// How much time should the node wait before trying to reconnect
  /// to lavalink server again
  late final Duration delayBetweenReconnections;
  /// Client id
  late final Snowflake clientId;
  /// Node id, you **must** not set this yourself
  late final int nodeId;

  /// Constructor to build a new node builder
  NodeOptions({
    this.host = "localhost",
    this.port = 2333,
    this.ssl = false,
    this.password = "youshallnotpass",
    this.shards = 1,
    this.maxConnectAttempts = 5,
    this.delayBetweenReconnections = const Duration(seconds: 5)
  });

  NodeOptions._fromJson(Map<String, dynamic> json) {
    host = json["host"] as String;
    port = json["port"] as int;
    ssl = json["ssl"] as bool;
    password = json["password"] as String;
    shards = json["shards"] as int;
    clientId = Snowflake(json["clientId"] as int);
    nodeId = json["nodeId"] as int;
    maxConnectAttempts = json["maxConnectAttempts"] as int;
    delayBetweenReconnections = Duration(milliseconds: json["delayBetweenReconnections"] as int);
  }

  Map<String, dynamic> _toJson() => {
    "host": this.host,
    "port": this.port,
    "ssl": this.ssl,
    "password": this.password,
    "shards": this.shards,
    "clientId": this.clientId.id,
    "nodeId": this.nodeId,
    "maxConnectAttempts": this.maxConnectAttempts,
    "delayBetweenReconnections": this.delayBetweenReconnections.inMilliseconds
  };
}
