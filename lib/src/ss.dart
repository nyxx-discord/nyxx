part of discord;

/// The SS server for the client.
class SSServer extends events.Events {
  /// The client that the SS server belongs to.
  Client client;

  /// The server socket;
  ServerSocket serverSocket;

  /// A list of all active sockets.
  List<Socket> sockets = <Socket>[];

  /// Makes a new SS server.
  SSServer(this.client) {
    this._newServer();
  }

  /// Sends a message to all shards.
  void send(String msg) {
    for (Socket socket in this.sockets) {
      socket.write(JSON.encode(<String, dynamic>{"op": 4, "d": msg}));
    }
  }

  Future<Null> _newServer() async {
    this.serverSocket = await ServerSocket.bind('0.0.0.0', 10048);
    await for (Socket socket in serverSocket) {
      this.sockets.add(socket);
      socket.transform(UTF8.decoder).listen(
          (String msg) => this._handleMsg(socket, msg),
          onDone: () => this.sockets.remove(socket));
    }
  }

  Future<Null> _handleMsg(Socket socket, String msg) async {
    final data = JSON.decode(msg) as Map<String, dynamic>;

    if (data['t'] != this.client._token) {
      socket.write(JSON.encode(<String, dynamic>{"op": 0, "d": 0}));
      socket.destroy();
    }
    switch (data['op']) {
      case 1:
        if (data['t'] == this.client._token) {
          socket.write(JSON.encode(<String, dynamic>{"op": 2, "d": null}));
        } else {
          socket.write(JSON.encode(<String, dynamic>{"op": 0, "d": 0}));
          socket.destroy();
        }
        break;

      case 4:
        this.emit('message', data['d']);
        break;
    }

    return null;
  }
}

/// The SS client for the client.
class SSClient extends events.Events {
  /// The client that the SS client belongs to.
  Client client;

  /// The SS server's address.
  String address;

  /// The socket.
  Socket socket;

  /// Makes a new SS client.
  SSClient(this.client);

  /// Connects to a SS server.
  void connect([String address]) {
    if (address != null) {
      this.address = address;
    }
    Socket.connect(this.address, 10048).then((Socket socket) {
      this.socket = socket;
      this.socket.transform(UTF8.decoder).listen(this._handleMsg);
      this.socket.write(JSON.encode(
          <String, dynamic>{"op": 1, "d": null, "t": this.client._token}));
    });
  }

  /// Sends a message to shard 0.
  void send(String msg) {
    socket.write(JSON.encode(<String, dynamic>{
      "op": 4,
      "t": this.client._token,
      "d": msg,
    }));
  }

  Future<Null> _handleMsg(String msg) async {
    final data = JSON.decode(msg) as Map<String, dynamic>;
    switch (data['op']) {
      case 2:
        this.emit('ready', null);
        break;

      case 3:
        new MessageEvent(this.client, data['d'] as Map<String, dynamic>);
        break;

      case 4:
        this.emit('message', data['d']);
        break;
    }

    return null;
  }
}
