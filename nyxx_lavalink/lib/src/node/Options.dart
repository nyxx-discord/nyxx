part of nyxx_lavalink;

/// Builder options for creating a lavalink node
class NodeOptions {
  /// Host where lavalink is running
  String host;
  /// Port used by lavalink rest & socket
  int port;
  /// Whether to use a tls connection or not
  bool ssl;
  /// Password to connect to the server
  String password;
  /// Shards the bot is operating on
  int shards;
  /// Client id
  Snowflake clientId;


  /// Constructor to build a new node builder
  NodeOptions({
    required this.clientId,
    this.host = "localhost",
    this.port = 2333,
    this.ssl = false,
    this.password = "youshallnotpass",
    this.shards = 1,
  });

  NodeOptions._fromJson(Map<String, dynamic> json)
      : host = json["host"] as String,
        port = json["port"] as int,
        ssl = json["ssl"] as bool,
        password = json["password"] as String,
        shards = json["shards"] as int,
        clientId = Snowflake(json["clientId"] as int);

  Map<String, dynamic> _toJson() => {
    "host": this.host,
    "port": this.port,
    "ssl": this.ssl,
    "password": this.password,
    "shards": this.shards,
    "clientId": this.clientId.id
  };
}