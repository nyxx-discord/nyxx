import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../discord.dart';
import 'package:events/events.dart' as events;

/// The SS server for the client.
class SSServer extends events.Events {
  /// The client that the SS server belongs to.
  Client client;

  /// The server socket;
  ServerSocket serverSocket;

  /// Makes a new SS server.
  SSServer(this.client) {
    this._newServer();
  }

  Future<Null> _newServer() async {
    this.serverSocket = await ServerSocket.bind('0.0.0.0', 10048);
    await for (var socket in serverSocket) {
      socket.transform(UTF8.decoder).listen((String msg) => this._handleMsg(socket, msg));
    }
  }

  Future<Null> _handleMsg(Socket socket, String msg) async {
    Map<String, dynamic> data = JSON.decode(msg);
    switch (data['op']) {
      case 1:
        if (data['t'] == this.client.token) {
          socket.write(JSON.encode({"op": 2, "d": null}));
        } else {
          socket.write(JSON.encode({"op": 0, "d": 0}));
          socket.destroy();
        }
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
  SSClient(this.client) {

  }

  /// Connects to a SS server.
  void connect([String address]) {
    if (address != null) {
      this.address = address;
    }
    Socket.connect(this.address, 10048).then((Socket socket) {
      this.socket = socket;
      this.socket.transform(UTF8.decoder).listen(this._handleMsg);
      this.socket.write(JSON.encode({"op": 1, "d": null, "t": this.client.token}));
    });
  }

  Future<Null> _handleMsg(String msg) async {
    Map<String, dynamic> data = JSON.decode(msg);
    switch (data['op']) {
      case 2:
        this.emit('ready', null);
        break;
    }

    return null;
  }
}
