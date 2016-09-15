import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'objects.dart';
import 'http.dart';

class Client {
  Map _defaultOptions = {
   "bot": true,
    "internal": {
      "ws": {
        "large_threshold": 100
      }
    }
  };

  var _socket;
  int _lastS = null;
  API _api = new API();
  ObjectManager _om;
  Map _handlers = {
    "ready": [],
    "message": []
  };

  _heartbeat() {
    return JSON.encode({"op": 1,"d": this._lastS});
  }

  _handleMsg(msg) {
    //print('Message received: $msg');
    var json = JSON.decode(msg);

    if (json['s'] != null) {
      this._lastS = json['s'];
    }

    //const ms = const JSON.decode(msg)["d"]["heartbeat_interval"];

    if (json["op"] == 10) {
      const heartbeat_interval = const Duration(milliseconds: 41250);
      new Timer.periodic(heartbeat_interval, (Timer t) => this._socket.add(this._heartbeat()));

      this._socket.add(JSON.encode({
        "op": 2,
        "d": {
          "token": this.token,
          "properties": {
            "\$browser": "Discord Dart"
          },
          "large_threshold": this.options['internal']['ws']['large_threshold'],
          "compress": false
        }
      }));
    } else if (json["op"] == 0) {
      if (json['t'] == "READY") {
        this._handlers['ready'].forEach((function) => function());
      } else if (json['t'] == "MESSAGE_CREATE") {
        Message message = new Message(json['d']);
        this._handlers['message'].forEach((function) => function(message));
      }
    }
  }



  String token;
  Map options;

  Client(String token, [Map options = const {}]) {
    this.options = this._defaultOptions..addAll(options);

    if (this.options['bot']) {
      this.token = "Bot $token";
    } else {
      this.token = token;
    }

    this._api.headers['Authorization'] = this.token;
    this._om = new ObjectManager(this._api);

    WebSocket.connect('wss://gateway.discord.gg?v=6&encoding=json').then((socket) {
      this._socket = socket;
      this._socket.listen(this._handleMsg);
    });
  }

  onEvent(String event, function) {
    if (this._handlers.keys.contains(event.toLowerCase())) {
      this._handlers[event].add(function);
      return this._handlers[event].indexOf(function);
    } else {
      throw new Exception("invalid event handler '$event'");
    }
  }

  sendMessage(String channel, String content) async {
    var r = await this._api.post('channels/$channel/messages', {"content": content});
    Map res = JSON.decode(r.body);

    if (r.statusCode == 200) {
      return new Message(res);
    } else {
      throw new Exception("${res['code']}: ${res['message']}");
    }
  }
}
