part of nyxx;

/// Represents private channel with user
class ThreadGuildChannel extends GuildChannel implements TextChannel {

  final List<ThreadMember> members = [];

  ThreadGuildChannel._new(INyxx client, Map<String, dynamic> raw, [Snowflake? guildId])
      : super._new(client, raw, guildId) {

    if(guildId == null) {
      // Add Exception.
      throw "GuildID Required";
    }

    for (final member in raw["members"] as List<Map<String, dynamic>>) {
      members.add(ThreadMember._new(client, member, guildId));
    }

  }

  @override
  Future<void> bulkRemoveMessages(Iterable<Message> messages) {
    // TODO: implement bulkRemoveMessages
    throw UnimplementedError();
  }

  @override
  Stream<Message> downloadMessages({int limit = 50, Snowflake? after, Snowflake? around, Snowflake? before}) {
    // TODO: implement downloadMessages
    throw UnimplementedError();
  }

  @override
  Future<Message> fetchMessage(Snowflake id) {
    // TODO: implement fetchMessage
    throw UnimplementedError();
  }

  @override
  // TODO: implement fileUploadLimit
  Future<int> get fileUploadLimit => throw UnimplementedError();

  @override
  Message? getMessage(Snowflake id) {
    // TODO: implement getMessage
    throw UnimplementedError();
  }

  @override
  // TODO: implement messageCache
  MessageCache get messageCache => throw UnimplementedError();

  @override
  Future<Message> sendMessage(MessageBuilder builder) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<void> startTyping() {
    // TODO: implement startTyping
    throw UnimplementedError();
  }

  @override
  void startTypingLoop() {
    // TODO: implement startTypingLoop
  }

  @override
  void stopTypingLoop() {
    // TODO: implement stopTypingLoop
  }

}