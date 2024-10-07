import 'package:nyxx/src/builders/soundboard.dart';
import 'package:nyxx/src/http/managers/soundboard_manager.dart';
import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';

class PartialSoundboardSound extends ManagedSnowflakeEntity<SoundboardSound> {
  @override
  final SoundboardManager manager;

  PartialSoundboardSound({required super.id, required this.manager});

  /// Update this entity using the provided builder and return the updated entity.
  Future<SoundboardSound> update(UpdateSoundBuilder builder) {
    assert(manager is GuildSoundboardManager);

    return (manager as GuildSoundboardManager).update(id, builder);
  }

  /// Delete this entity.
  Future<void> delete() {
    assert(manager is GuildSoundboardManager);

    return (manager as GuildSoundboardManager).delete(id);
  }
}

class SoundboardSound extends PartialSoundboardSound {
  /// The name of this sound.
  final String name;

  /// The volume of this sound, from 0 to 1.
  final double volume;

  /// The emoji this sound is associated with.
  final Emoji? emoji;

  /// The emoji name this sound is associated with.
  final String? emojiName;

  /// The emoji ID this sound is associated with.
  final Snowflake? emojiId;

  /// The ID of the guild this sound is in.
  final Snowflake? guildId;

  /// Whether this sound can be used, may be `false` due to loss of Server Boosts.
  final bool isAvailable;

  /// The user who created this sound.
  final User? user;

  SoundboardSound({
    required super.id,
    required super.manager,
    required this.name,
    required this.volume,
    required this.emoji,
    required this.emojiName,
    required this.emojiId,
    required this.guildId,
    required this.isAvailable,
    required this.user,
  });

  PartialGuild get guild => manager.client.guilds[guildId!];
}
