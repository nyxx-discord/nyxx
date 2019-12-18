/// Nyxx Discord API wrapper for Dart
///
/// Main library which contains all stuff needed to connect and interact with Discord API.
library nyxx;

import 'dart:async';

import 'dart:convert';
import 'dart:collection';
import 'dart:io';

// Used to discard errors on vm to continue working even if error occured
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:w_transport/w_transport.dart' as transport;

import 'src/_internals.dart';

// BASE

part 'src/Nyxx.dart';
part 'src/ClientOptions.dart';

// INTERNAL

part 'src/internal/_Constants.dart';
part 'src/internal/_EventController.dart';
part 'src/internal/_WS.dart';
part 'src/internal/Http.dart';
part 'src/internal/Cache.dart';

// ERROR

part 'src/errors/HttpError.dart';
part 'src/errors/SetupErrors.dart';

// EVENTS

part 'src/events/DisconnectEvent.dart';
part 'src/events/PresenceUpdateEvent.dart';
part 'src/events/RatelimitEvent.dart';
part 'src/events/RawEvent.dart';
part 'src/events/ReadyEvent.dart';
part 'src/events/TypingEvent.dart';

part 'src/events/VoiceServerUpdateEvent.dart';
part 'src/events/VoiceStateUpdateEvent.dart';
part 'src/events/UserUpdateEvent.dart';

part 'src/events/MessageEvents.dart';
part 'src/events/HttpEvents.dart';
part 'src/events/ChannelEvents.dart';
part 'src/events/GuildEvents.dart';

// BUILDERS

part 'src/builders/Builder.dart';

part 'src/builders/AttachmentBuilder.dart';
part 'src/builders/PermissionsBuilder.dart';
part 'src/builders/EmbedBuilder.dart';
part 'src/builders/EmbedAuthorBuilder.dart';
part 'src/builders/EmbedFieldBuilder.dart';
part 'src/builders/EmbedFooterBuilder.dart';
part 'src/builders/GuildBuilder.dart';
part 'src/builders/MessageBuilder.dart';

// OBJECTS

part 'src/objects/Convertable.dart';
part 'src/objects/ISend.dart';
part 'src/objects/Mentionable.dart';
part 'src/objects/GuildEntity.dart';
part 'src/objects/Disposable.dart';
part 'src/objects/Downloadable.dart';

part 'src/objects/DiscordColor.dart';

part 'src/objects/SnowflakeEntity.dart';
part 'src/objects/Snowflake.dart';
part 'src/Shard.dart';
part 'src/objects/guild/Webhook.dart';

part 'src/objects/voice/VoiceState.dart';
part 'src/objects/voice/VoiceRegion.dart';

part 'src/objects/Invite.dart';

part 'src/objects/auditlogs/AuditLog.dart';
part 'src/objects/auditlogs/AuditLogEntry.dart';
part 'src/objects/auditlogs/AuditLogChange.dart';

part 'src/objects/channel/VoiceChannel.dart';
part 'src/objects/channel/CategoryChannel.dart';
part 'src/objects/channel/TextChannel.dart';
part 'src/objects/channel/GuildChannel.dart';
part 'src/objects/channel/GroupDMChannel.dart';
part 'src/objects/channel/DMChannel.dart';
part 'src/objects/channel/Channel.dart';
part 'src/objects/channel/MessageChannel.dart';

part 'src/objects/embed/EmbedField.dart';
part 'src/objects/embed/EmbedAuthor.dart';
part 'src/objects/embed/EmbedFooter.dart';
part 'src/objects/embed/EmbedVideo.dart';
part 'src/objects/embed/Embed.dart';
part 'src/objects/embed/EmbedProvider.dart';
part 'src/objects/embed/EmbedThumbnail.dart';

part 'src/objects/guild/ClientUser.dart';
part 'src/objects/guild/Guild.dart';
part 'src/objects/user/Presence.dart';
part 'src/objects/user/Member.dart';
part 'src/objects/guild/Status.dart';
part 'src/objects/guild/Role.dart';
part 'src/objects/user/User.dart';
part 'src/objects/guild/Ban.dart';

part 'src/objects/message/UnicodeEmoji.dart';
part 'src/objects/message/GuildEmoji.dart';
part 'src/objects/message/Emoji.dart';
part 'src/objects/message/Reaction.dart';
part 'src/objects/message/Message.dart';
part 'src/objects/message/Attachment.dart';

part 'src/objects/oauth/ClientOAuth2Application.dart';
part 'src/objects/oauth/OAuth2Application.dart';
part 'src/objects/oauth/OAuth2Guild.dart';
part 'src/objects/oauth/OAuth2Info.dart';

part 'src/objects/permissions/Permissions.dart';
part 'src/objects/permissions/AbstractPermissions.dart';
part 'src/objects/permissions/PermissionOverrides.dart';
part 'src/objects/permissions/PermissionsConstants.dart';

part 'src/utils/permissions.dart';
part 'src/utils/downloads.dart';
part 'src/utils/utils.dart';
