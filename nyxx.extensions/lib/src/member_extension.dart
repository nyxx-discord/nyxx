import "package:nyxx/nyxx.dart";

/// Collection of extensions for [Member]
extension MemberExtension on User {
  /// Fetches all mutual guilds for [User] that bot has access to.
  /// Note it will try to download users via REST api so bot could get rate limited.
  Future<Map<Guild, Member>> fetchMutualGuilds() async {
    final result = <Guild, Member>{};

    for (final guild in this.client.guilds.values) {
      try {
        final member = guild.members[this.id]
          ?? await guild.fetchMember(this.id);

        result[guild] = member;
      // ignore: empty_catches
      } on Exception { }
    }

    return result;
  }
}
