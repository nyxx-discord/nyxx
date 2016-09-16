class User {
  String username;
  String id;
  String discriminator;
  String avatar;
  String mention;
  bool bot = false;

  User(Map data) {
    this.username = data['username'];
    this.id = data['id'];
    this.discriminator = data['discriminator'];
    this.avatar = data['avatar'];
    this.mention = "<@${this.id}>";

    if (data['bot']) {
      this.bot = data['bot'];
    }
  }
}

class Member {
  String nickname;
  String joinedAt;
  bool deaf;
  bool mute;
  List<String> roles;
  User user;

  Member(Map data) {
    this.nickname = data['nick'];
    this.joinedAt = data['joined_at'];
    this.deaf = data['deaf'];
    this.mute = data['mute'];
    this.roles = data['roles'];
    this.user = new User(data['user']);
  }
}

class Guild {
  String name;
  String id;
  String icon;
  String afkChannelID;
  String region;
  String embedChannelID;
  int afkTimeout;
  int memberCount;
  int verificationLevel;
  int notificationLevel;
  int mfaLevel;
  bool large;
  bool embedEnabled;
  User ownerID;
  Map<String, Member> members = {};

  Guild(Map data, bool guildCreate) {
    this.name = data['name'];
    this.id = data['id'];
    this.icon = data['icon'];
    this.afkChannelID = data['afk_channel_id'];
    this.region = data['region'];
    this.embedChannelID = data['embed_channel_id'];
    this.afkTimeout = data['afk_timeout'];
    this.memberCount = data['member_count'];
    this.verificationLevel = data['verification_level'];
    this.notificationLevel = data['default_message_notifications'];
    this.mfaLevel = data['default_message_notifications'];
    this.embedEnabled = data['embed_enabled'];
    this.ownerID = data['owner_id'];

    if (guildCreate) {
      this.large = data['large'];
      //this.roles = JSON.decode(data['roles']);
      data['members'].forEach((i) {
        //print(data['members'][i]);
        Member member = new Member(data['members'][0]);
        print(member);
        this.members[member.user.id] = member;
      });
    }
  }
}

class Channel {
  String name;
  String id;
  String topic;
  String type;
  String lastMessageID;
  String guildID;
  int position;
  int bitrate;
  int userLimit;
  bool isPrivate;

  Channel(Map data) {
    this.name = data['name'];
    this.id = data['id'];
    this.type = data['type'];
    this.guildID = data['guild_id'];
    this.position = data['position'];
    this.isPrivate = data['is_private'];

    if (this.type == "text") {
      this.topic = data['topic'];
      this.lastMessageID = data['last_message_id'];
    } else {
      this.bitrate = data['bitrate'];
      this.userLimit = data['user_limit'];
    }
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
  List<User> mentions = [];
  List<String> roleMentions = [];
  List<Embed> embeds = [];
  List<Attachment> attachments = [];
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
    this.roleMentions = data['mention_roles'];

    data['mentions'].forEach((user) {
      this.mentions.add(new User(user));
    });

    data['embeds'].forEach((embed) {
      this.embeds.add(new Embed(embed));
    });

    data['attachments'].forEach((attachment) {
      this.attachments.add(new Attachment(attachment));
    });
  }
}

class Attachment {
  String id;
  String filename;
  String url;
  String proxyUrl;
  int size;
  int height;
  int width;

  Attachment(Map data) {
    this.id = data['id'];
    this.filename = data['filename'];
    this.url = data['url'];
    this.proxyUrl = data['proxyUrl'];
    this.size = data['size'];
    this.height = data['height'];
    this.width = data['width'];
  }
}

class EmbedThumbnail {
  String url;
  String proxyUrl;
  int height;
  int width;

  EmbedThumbnail(Map data) {
    this.url = data['url'];
    this.proxyUrl = data['proxy_url'];
    this.height = data['height'];
    this.width = data['width'];
  }
}

class EmbedProvider {
  String name;
  String url;

  EmbedProvider(Map data) {
    this.name = data['name'];
    this.url = data['url'];
  }
}

class Embed {
  String url;
  String type;
  String description;
  String title;
  EmbedThumbnail thumbnail;
  EmbedProvider provider;

  Embed(Map data) {
    this.url = data['url'];
    this.type = data['type'];
    this.description = data['description'];

    if (data.containsKey('thumbnail')) {
      this.thumbnail = new EmbedThumbnail(data['thumbnail']);
    }
    if (data.containsKey('provider')) {
      this.provider = new EmbedProvider(data['provider']);
    }
  }
}

class InviteGuild {
  String id;
  String name;
  String spash;

  InviteGuild(Map data) {
    this.id = data['id'];
    this.name = data['name'];
    this.spash = data['splash_hash'];
  }
}

class InviteChannel {
  String id;
  String name;
  String type;

  InviteChannel(Map data) {
    this.id = data['id'];
    this.name = data['name'];
    this.type = data['type'];
  }
}

class Invite {
  String code;
  InviteGuild guild;
  InviteChannel channel;

  Invite(Map data) {
    this.code = data['code'];
    this.guild = new InviteGuild(data['guild']);
    this.channel = new InviteChannel(data['channel']);
  }
}
