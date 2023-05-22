import 'package:nyxx/src/builders/permission_overwrite.dart';
import 'package:nyxx/src/models/channel/channel.dart';
import 'package:nyxx/src/models/permission_overwrite.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/webhook.dart';

/// A channel in a [Guild].
abstract class GuildChannel implements Channel {
  /// The ID of the [Guild] this channel is in.
  Snowflake get guildId;

  /// The positing on this channel in the guild's channel list.
  int get position;

  /// The permission overwrites for members and roles in this channel.
  List<PermissionOverwrite> get permissionOverwrites;

  /// The name of this channel.
  String get name;

  /// Whether this channel is marked as NSFW.
  bool get isNsfw;

  /// The ID of this channel's parent.
  ///
  /// This will be the ID of a [GuildCategory] for non-thread channels, and the ID of a [HasThreadsChannel] for [Thread]s.
  Snowflake? get parentId;

  /// Update or create a permission overwrite in this channel.
  ///
  /// External references:
  /// * [ChannelManager.updatePermissionOverwrite]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#edit-channel-permissions
  Future<void> updatePermissionOverwrite(PermissionOverwriteBuilder builder);

  /// Remove a permission overwrite from this channel.
  ///
  /// External references:
  /// * [ChannelManager.deletePermissionOverwrite]
  /// * Discord API Reference: https://discord.com/developers/docs/resources/channel#delete-channel-permission
  Future<void> deletePermissionOverwrite(Snowflake id);

  Future<List<Webhook>> fetchWebhooks();
}
