part of nyxx;

/// Given when a thread is created as only partial information is available. If you want the final channel use [getThreadChannel]
class ThreadPreviewChannel extends IChannel {
  late final INyxx _client;
  /// Name of the channel
  late final String name;

  /// Approximate message count
  late final int messageCount;

  /// Approximate member count
  late final int memberCount;

  /// Guild where the thread is located
  late final Cacheable<Snowflake, Guild> guild;

  /// The text channel where the thread was made
  late final Cacheable<Snowflake, TextChannel> parentChannel;

  /// Initial author of the thread
  late final Cacheable<Snowflake, Member> owner;

  /// Preview of initial members
  late final List<Cacheable<Snowflake, Member>> memberPreview;

  /// If the thread has been archived
  late final bool archived;

  /// When the thread will be archived
  late final DateTime archivedTime;

  /// How long till the thread is archived
  late final ThreadArchiveTime archivedAfter;

  ThreadPreviewChannel._new(INyxx this._client, Map<String, dynamic> raw) : super._new(_client, raw) {
    this.name = raw["name"] as String;
    this.messageCount = raw["message_count"] as int;
    this.memberCount = raw["member_count"] as int;
    this.parentChannel = CacheUtility.createCacheableTextChannel(client, Snowflake(raw["parent_id"]));
    this.guild = CacheUtility.createCacheableGuild(client, Snowflake(raw["guild_id"]));
    this.owner = CacheUtility.createCacheableMember(client, Snowflake(raw["owner_id"]), this.guild);
    this.memberPreview = [];
    if(raw["member_ids_preview"] != null) {
      for(final String id in raw["member_ids_preview"] as List<String>) {
        this.memberPreview.add(CacheUtility.createCacheableMember(client, Snowflake(id), this.guild));
      }
    }
    final metadata = raw["thread_metadata"] as Map<String, dynamic>;

    this.archived = metadata["archived"] as bool;
    this.archivedTime = DateTime.parse(metadata["archive_timestamp"] as String);
    this.archivedAfter = ThreadArchiveTime._new(metadata["auto_archive_duration"] as int);
  }

  /// Get the actual thread channel from the preview
  _ChannelCacheable<ThreadChannel> getThreadChannel() => new _ChannelCacheable(_client, this.id);
}
