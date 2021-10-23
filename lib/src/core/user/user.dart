import 'dart:async';

import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/channel/dm_channel.dart';
import 'package:nyxx/src/core/guild/status.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/user/nitro_type.dart';
import 'package:nyxx/src/core/user/presence.dart';
import 'package:nyxx/src/core/user/user_flags.dart';
import 'package:nyxx/src/internal/interfaces/message_author.dart';
import 'package:nyxx/src/internal/interfaces/send.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';

abstract class IUser implements SnowflakeEntity, ISend, Mentionable, IMessageAuthor {
  /// Reference to client
  INyxx get client;

  /// The user's username.
  @override
  String get username;

  /// The user's discriminator.
  @override
  int get discriminator;

  /// Formatted discriminator with leading zeros if needed
  String get formattedDiscriminator => discriminator.toString().padLeft(4, "0");

  /// The user's avatar hash.
  String? get avatar;

  /// The string to mention the user.
  @override
  String get mention => "<@!${this.id}>";

  /// Returns String with username#discriminator
  @override
  String get tag => "${this.username}#${this.formattedDiscriminator}";

  /// Whether the user belongs to an OAuth2 application
  @override
  bool get bot;

  /// Whether the user is an Official Discord System user (part of the urgent message system)
  bool get system;

  /// The member's status. `offline`, `online`, `idle`, or `dnd`.
  IClientStatus? get status;

  /// The member's presence.
  Activity? get presence;

  /// Additional flags associated with user account. Describes if user has certain
  /// features like joined into one of houses or is discord employee.
  IUserFlags? get userFlags;

  /// Premium types denote the level of premium a user has.
  NitroType? get nitroType;

  /// Hash of user banner
  String? get bannerHash;

  /// Color of the banner
  DiscordColor? get accentColor;

  /// Gets the [DMChannel] for the user.
  FutureOr<IDMChannel> get dmChannel;

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned with specified size and png format.
  @override
  String avatarURL({String format = "webp", int size = 128});

  /// Sends a message to user.
  @override
  Future<IMessage> sendMessage(MessageBuilder builder);
}

/// Represents a single user of Discord, either a human or a bot, outside of any specific guild's context.
class User extends SnowflakeEntity implements IUser {
  /// Reference to client
  @override
  final INyxx client;

  /// The user's username.
  @override
  late final String username;

  /// The user's discriminator.
  @override
  late final int discriminator;

  /// Formatted discriminator with leading zeros if needed
  @override
  String get formattedDiscriminator => discriminator.toString().padLeft(4, "0");

  /// The user's avatar hash.
  @override
  late final String? avatar;

  /// The string to mention the user.
  @override
  String get mention => "<@!${this.id}>";

  /// Returns String with username#discriminator
  @override
  String get tag => "${this.username}#${this.formattedDiscriminator}";

  /// Whether the user belongs to an OAuth2 application
  @override
  late final bool bot;

  /// Whether the user is an Official Discord System user (part of the urgent message system)
  @override
  late final bool system;

  /// The member's status. `offline`, `online`, `idle`, or `dnd`.
  @override
  IClientStatus? status;

  /// The member's presence.
  @override
  Activity? presence;

  /// Additional flags associated with user account. Describes if user has certain
  /// features like joined into one of houses or is discord employee.
  @override
  late final IUserFlags? userFlags;

  /// Premium types denote the level of premium a user has.
  @override
  late final NitroType? nitroType;

  /// Hash of user banner
  @override
  late final String? bannerHash;

  /// Color of the banner
  @override
  late final DiscordColor? accentColor;

  /// Creates an instance of [User]
  User(this.client, RawApiMap raw) : super(Snowflake(raw["id"])) {
    this.username = raw["username"] as String;
    this.discriminator = int.parse(raw["discriminator"] as String);
    this.avatar = raw["avatar"] as String?;
    this.bot = raw["bot"] as bool? ?? false;
    this.system = raw["system"] as bool? ?? false;

    if (raw["public_flags"] != null) {
      this.userFlags = UserFlags(raw["public_flags"] as int);
    } else {
      this.userFlags = null;
    }

    if (raw["premium_type"] != null) {
      this.nitroType = NitroType.from(raw["premium_type"] as int);
    } else {
      this.nitroType = null;
    }

    this.bannerHash = raw["banner"] as String?;
    if (raw["accent_color"] != null) {
      this.accentColor = DiscordColor.fromInt(raw["accent_color"] as int);
    } else {
      this.accentColor = null;
    }
  }

  /// Gets the [DMChannel] for the user.
  @override
  FutureOr<IDMChannel> get dmChannel {
    try {
      return client.channels.values.firstWhere((item) => item is IDMChannel && item.participants.contains(this)) as Future<IDMChannel>;
    } on StateError {
      return client.httpEndpoints.createDMChannel(this.id);
    }
  }

  /// The user's avatar, represented as URL.
  /// In case if user does not have avatar, default discord avatar will be returned with specified size and png format.
  @override
  String avatarURL({String format = "webp", int size = 128}) =>
      client.httpEndpoints.userAvatarURL(this.id, this.avatar, this.discriminator, format: format, size: size);

  /// Sends a message to user.
  @override
  Future<IMessage> sendMessage(MessageBuilder builder) async {
    final channel = await this.dmChannel;
    return channel.sendMessage(builder);
  }
}
