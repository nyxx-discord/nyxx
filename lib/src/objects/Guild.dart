import '../../objects.dart';
import '../client.dart';

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
  GuildChannel defaultChannel;

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

  /// If the guild's widget is enabled.
  bool embedEnabled;

  /// Whether or not the guild is available.
  bool available = true;

  /// The guild owner's ID
  String ownerID;

  /// The guild's members.
  Map<String, Member> members = <String, Member>{};

  /// The guild's channels.
  Map<String, GuildChannel> channels = <String, GuildChannel>{};

  /// Constructs a new [Guild].
  Guild(Client client, Map<String, dynamic> data, [bool available = true, bool guildCreate = false]) {
    if (available) {
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
        //this.roles = JSON.decode(data['roles']);
        data['members'].forEach((Map<String, dynamic> o) {
          Member member = new Member(o, this);
          this.members[member.user.id] = member;
        });

        data['channels'].forEach((Map<String, dynamic> o) {
          GuildChannel channel = new GuildChannel(client, o, this);
          this.channels[channel.id] = channel;
        });

        this.defaultChannel = this.channels[this.id];
      }
    } else {
      this.available = false;
    }
  }
}
