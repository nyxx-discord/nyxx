import '../../discord.dart';


/// A guild.
class Guild {
  /// The guild's name.
  String name;

  /// The guild's ID.
  String id;

  /// The guild's icon hash.
  String icon;

  /// The guild's afk channel ID, null if not set.
  String afkChannelID;

  /// The guild's voice region.
  String region;

  /// The channel ID for the guild's widget if enabled.
  String embedChannelID;

  /// The guild's default channel.
  Channel defaultChannel;

  /// The guild's AFK timeout.
  int afkTimeout;

  /// The guild's member count.
  int memberCount;

  /// The guild's verification level.
  int verificationLevel;

  /// The guild's notification level.
  int notificationLevel;

  /// The guild's MFA level.
  int mfaLevel;

  /// A timestamp for when the guild was created.
  double createdAt;

  /// Whether or not the guild has over 100 members.
  bool large;

  /// If the guild's widget is enabled.
  bool embedEnabled;

  /// The guild owner's ID
  User ownerID;

  /// The guild's members.
  Map<String, Member> members = {};

  /// The guild's channels.
  Map<String, Channel> channels = {};

  Guild(Client client, Map data, bool guildCreate) {
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
    this.mfaLevel = data['mfa_level'];
    this.embedEnabled = data['embed_enabled'];
    this.ownerID = data['owner_id'];
    this.createdAt = (int.parse(this.id) / 4194304) + 1420070400000;

    if (guildCreate) {
      this.large = data['large'];
      //this.roles = JSON.decode(data['roles']);
      data['members'].forEach((o) {
        Member member = new Member(o);
        this.members[member.user.id] = member;
      });

      data['channels'].forEach((o) {
        Channel channel = new Channel(client, o, this);
        this.channels[channel.id] = channel;
      });

      this.defaultChannel = this.channels[this.id];
    }
  }
}
