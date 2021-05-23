part of nyxx;

class ThreadPreviewChannel extends IChannel {
  late final INyxx _client;
  late final String name;
  late final int messageCount;
  late final int memberCount;
  late final Cacheable<Snowflake, Guild> guild;
  late final Cacheable<Snowflake, TextChannel> parentChannel;
  late final Cacheable<Snowflake, Member> owner;
  late final List<Cacheable<Snowflake, Member>> memberPreview;
  late final bool archived;
  late final DateTime archivedTime;
  late final ThreadArchiveTime archivedAfter;

  ThreadPreviewChannel._new(INyxx client, Map<String, dynamic> raw) : super._new(client, raw) {
    this._client = client;
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

  _ChannelCacheable<ThreadChannel> getThreadChannel() => new _ChannelCacheable(_client, this.id);
}