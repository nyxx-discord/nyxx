/// Nyxx Discord API wrapper for Dart
///
/// Main library which contains all stuff needed to connect and interact with Discord API.
/// If you want advanced command capabilities refer to `nyxx.command` library.
///
/// To get connected your bot to voice refer to `nyxx.lavalink` library.
///
/// Library creates global variable for [Nyxx] client. So there is no need to keep instance of client.
library nyxx;

import 'dart:async';

import 'dart:convert';
import 'dart:collection';
import 'dart:io';

import 'dart:isolate';

import 'package:logging/logging.dart';

import 'package:w_transport/w_transport.dart' as transport;
import 'package:w_transport/vm.dart' as transport;

import 'utils.dart' as utils;

// BASE

part 'src/nyxx/Nyxx.dart';
part 'src/nyxx/ClientOptions.dart';

// INTERNAL

part 'src/nyxx/internal/_Constants.dart';
part 'src/nyxx/internal/_EventController.dart';
part 'src/nyxx/internal/_WS.dart';
part 'src/nyxx/internal/Http.dart';
part 'src/nyxx/internal/Cache.dart';

// ERROR

part 'src/nyxx/errors/HttpError.dart';

// EVENTS

part 'src/nyxx/events/DisconnectEvent.dart';
part 'src/nyxx/events/PresenceUpdateEvent.dart';
part 'src/nyxx/events/RatelimitEvent.dart';
part 'src/nyxx/events/RawEvent.dart';
part 'src/nyxx/events/ReadyEvent.dart';
part 'src/nyxx/events/TypingEvent.dart';

part 'src/nyxx/events/VoiceServerUpdateEvent.dart';
part 'src/nyxx/events/VoiceStateUpdateEvent.dart';
part 'src/nyxx/events/WebhookUpdateEvent.dart';
part 'src/nyxx/events/UserUpdateEvent.dart';

part 'src/nyxx/events/MessageEvents.dart';
part 'src/nyxx/events/HttpEvents.dart';
part 'src/nyxx/events/ChannelEvents.dart';
part 'src/nyxx/events/GuildEvents.dart';

// BUILDERS

part 'src/nyxx/builders/Builder.dart';

part 'src/nyxx/builders/PermissionsBuilder.dart';
part 'src/nyxx/builders/EmbedBuilder.dart';
part 'src/nyxx/builders/EmbedAuthorBuilder.dart';
part 'src/nyxx/builders/EmbedFieldBuilder.dart';
part 'src/nyxx/builders/EmbedFooterBuilder.dart';
part 'src/nyxx/builders/GuildBuilder.dart';
part 'src/nyxx/builders/MessageBuilder.dart';

// OBJECTS

part 'src/nyxx/objects/ISend.dart';
part 'src/nyxx/objects/IMentionable.dart';
part 'src/nyxx/objects/GuildEntity.dart';
part 'src/nyxx/objects/Disposable.dart';
part 'src/nyxx/objects/Downloadable.dart';
part 'src/nyxx/objects/Nameable.dart';

part 'src/nyxx/objects/DiscordColor.dart';

part 'src/nyxx/objects/SnowflakeEntity.dart';
part 'src/nyxx/objects/Snowflake.dart';
part 'package:nyxx/src/nyxx/Shard.dart';
part 'src/nyxx/objects/guild/Webhook.dart';

part 'src/nyxx/objects/voice/VoiceState.dart';
part 'src/nyxx/objects/voice/VoiceRegion.dart';

part 'src/nyxx/objects/Invite.dart';

part 'src/nyxx/objects/auditlogs/AuditLog.dart';
part 'src/nyxx/objects/auditlogs/AuditLogEntry.dart';
part 'src/nyxx/objects/auditlogs/AuditLogChange.dart';

part 'src/nyxx/objects/channel/VoiceChannel.dart';
part 'src/nyxx/objects/channel/CategoryChannel.dart';
part 'src/nyxx/objects/channel/TextChannel.dart';
part 'src/nyxx/objects/channel/GuildChannel.dart';
part 'src/nyxx/objects/channel/GroupDMChannel.dart';
part 'src/nyxx/objects/channel/DMChannel.dart';
part 'src/nyxx/objects/channel/Channel.dart';
part 'src/nyxx/objects/channel/MessageChannel.dart';

part 'src/nyxx/objects/embed/EmbedField.dart';
part 'src/nyxx/objects/embed/EmbedAuthor.dart';
part 'src/nyxx/objects/embed/EmbedFooter.dart';
part 'src/nyxx/objects/embed/EmbedVideo.dart';
part 'src/nyxx/objects/embed/Embed.dart';
part 'src/nyxx/objects/embed/EmbedProvider.dart';
part 'src/nyxx/objects/embed/EmbedThumbnail.dart';

part 'src/nyxx/objects/guild/ClientUser.dart';
part 'src/nyxx/objects/guild/Guild.dart';
part 'src/nyxx/objects/user/Presence.dart';
part 'src/nyxx/objects/user/Member.dart';
part 'src/nyxx/objects/guild/Status.dart';
part 'src/nyxx/objects/guild/Role.dart';
part 'src/nyxx/objects/user/User.dart';
part 'src/nyxx/objects/guild/Ban.dart';

part 'src/nyxx/objects/message/UnicodeEmoji.dart';
part 'src/nyxx/objects/message/GuildEmoji.dart';
part 'src/nyxx/objects/message/Emoji.dart';
part 'src/nyxx/objects/message/Reaction.dart';
part 'src/nyxx/objects/message/Message.dart';
part 'src/nyxx/objects/message/Attachment.dart';

part 'src/nyxx/objects/OAuth/ClientOAuth2Application.dart';
part 'src/nyxx/objects/OAuth/OAuth2Application.dart';
part 'src/nyxx/objects/OAuth/OAuth2Guild.dart';
part 'src/nyxx/objects/OAuth/OAuth2Info.dart';

part 'src/nyxx/objects/permissions/Permissions.dart';
part 'src/nyxx/objects/permissions/AbstractPermissions.dart';
part 'src/nyxx/objects/permissions/PermissionOverrides.dart';
part 'src/nyxx/objects/permissions/PermissionsConstants.dart';
