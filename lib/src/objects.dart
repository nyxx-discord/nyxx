import 'client.dart';
import 'http.dart';
import 'dart:convert';

class ObjectManager {
  API _api;

  ObjectManager(API api) {
    this._api = api;
  }

  getChannel(String id) async {
    var r = await this._api.get('channels/$id');
    Map res = JSON.decode(r.body);
    if (r.statusCode == 200) {
      return new Channel(res);
    } else {
      throw new Exception("${res['code']}:${res['message']}");
    }
  }
}

class User {
  String username;
  String id;
  String discriminator;
  String avatar;
  bool bot = false;

  User(Map data) {
    this.username = data['username'];
    this.id = data['id'];
    this.discriminator = data['discriminator'];
    this.avatar = data['avatar'];

    if (data['bot']) {
      this.bot = data['bot'];
    }
  }
}

class Channel {
  String name;
  String id;
  String topic;
  String type;
  String lastMessageID;
  //Guild guild;
  int position;
  bool isPrivate;

  Channel(Map data) {
    this.name = data['name'];
    this.id = data['id'];
    this.topic = data['topic'];
    this.type = data['type'];
    this.lastMessageID = data['last_message_id'];
    //this.guild
    this.position = data['position'];
    this.isPrivate = data['is_private'];
  }
}

class Message {
  String content;
  String id;
  String nonce;
  String timestamp;
  String editedTimestamp;
  String channel;
  User author;
  List mentions;
  List roleMentions;
  bool pinned;
  bool tts;
  bool mentionEveryone;

  Message(Map data) {
    this.content = data['content'];
    this.id = data['id'];
    this.nonce = data['nonce'];
    this.timestamp = data['timestamp'];
    this.editedTimestamp = data['edited_timestamp'];
    this.author = new User(data['author']);
    this.channel = data['channel_id'];
    this.pinned = data['pinned'];
    this.tts = data['tts'];
    this.mentionEveryone = data['mention_everyone'];

    data['mentions'].forEach((user) {
      mentions.add(new User(user));
    });
  }
}
