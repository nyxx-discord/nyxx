part of discord;

/// The utility functions for the client.
class _Util {
  /// Gets a DateTime from a snowflake ID.
  static DateTime getDate(String id) {
    return new DateTime.fromMillisecondsSinceEpoch(
        ((int.parse(id) / 4194304) + 1420070400000).toInt());
  }

  /// Resolves an object into a target object.
  static String resolve(String to, dynamic object) {
    if (to == "channel") {
      if (object is Message) {
        return object.channel.id;
      } else if (object is Channel) {
        return object.id;
      } else if (object is Guild) {
        return object.defaultChannel.id;
      } else {
        return object.toString();
      }
    } else if (to == "message") {
      if (object is Message) {
        return object.id;
      } else {
        return object.toString();
      }
    } else if (to == "guild") {
      if (object is Message) {
        return object.guild.id;
      } else if (object is GuildChannel) {
        return object.guild.id;
      } else if (object is Guild) {
        return object.id;
      } else {
        return object.toString();
      }
    } else if (to == "user") {
      if (object is Message) {
        return object.author.id;
      } else if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.id;
      } else {
        return object.toString();
      }
    } else if (to == "member") {
      if (object is Message) {
        return object.author.id;
      } else if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.id;
      } else {
        return object.toString();
      }
    } else if (to == "app") {
      if (object is User) {
        return object.id;
      } else if (object is Member) {
        return object.id;
      } else {
        return object.toString();
      }
    } else {
      return null;
    }
  }
}
