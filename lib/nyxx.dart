/// Nyxx Discord API wrapper for Dart
///
/// Main sublibrary of nyxx provices basic functionality like access to http endpoints
/// of api or Websocket connectivity to interact with realtime events.
library nyxx;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:http/http.dart' as httpreq;

import 'utils.dart' as utils;

// BASE

part 'src/nyxx/Nyxx.dart';
part 'src/nyxx/ClientOptions.dart';

// INTERNAL

part 'src/nyxx/internal/_Constants.dart';
part 'src/nyxx/internal/_EventController.dart';
part 'src/nyxx/internal/_WS.dart';
part 'src/nyxx/internal/Http.dart';

// ERROR

part 'src/nyxx/errors/HttpError.dart';

// EVENTS

part 'src/nyxx/events/BeforeHttpRequestSendEvent.dart';
part 'src/nyxx/events/ChannelCreateEvent.dart';
part 'src/nyxx/events/ChannelDeleteEvent.dart';
part 'src/nyxx/events/ChannelUpdateEvent.dart';
part 'src/nyxx/events/DisconnectEvent.dart';
part 'src/nyxx/events/GuildBanAddEvent.dart';
part 'src/nyxx/events/GuildBanRemoveEvent.dart';
part 'src/nyxx/events/GuildCreateEvent.dart';
part 'src/nyxx/events/GuildDeleteEvent.dart';
part 'src/nyxx/events/GuildMemberAddEvent.dart';
part 'src/nyxx/events/GuildMemberRemoveEvent.dart';
part 'src/nyxx/events/GuildMemberUpdateEvent.dart';
part 'src/nyxx/events/GuildUnavailableEvent.dart';
part 'src/nyxx/events/GuildUpdateEvent.dart';
part 'src/nyxx/events/HttpErrorEvent.dart';
part 'src/nyxx/events/HttpResponseEvent.dart';
part 'src/nyxx/events/MessageDeleteEvent.dart';
part 'src/nyxx/events/MessageEvent.dart';
part 'src/nyxx/events/MessageUpdateEvent.dart';
part 'src/nyxx/events/PresenceUpdateEvent.dart';
part 'src/nyxx/events/RatelimitEvent.dart';
part 'src/nyxx/events/RawEvent.dart';
part 'src/nyxx/events/ReadyEvent.dart';
part 'src/nyxx/events/RoleCreateEvent.dart';
part 'src/nyxx/events/RoleDeleteEvent.dart';
part 'src/nyxx/events/RoleUpdateEvent.dart';
part 'src/nyxx/events/TypingEvent.dart';
part 'src/nyxx/events/ChannelPinsUpdateEvent.dart';
part 'src/nyxx/events/GuildEmojisUpdateEvent.dart';
part 'src/nyxx/events/MessageDeleteBulkEvent.dart';
part 'src/nyxx/events/MessageReactionEvent.dart';
part 'src/nyxx/events/MessageReactionsRemovedEvent.dart';
part 'src/nyxx/events/VoiceServerUpdateEvent.dart';
part 'src/nyxx/events/VoiceStateUpdateEvent.dart';
part 'src/nyxx/events/WebhookUpdateEvent.dart';
part 'src/nyxx/events/UserUpdateEvent.dart';

// BUILDERS

part 'src/nyxx/builders/Builder.dart';

part 'src/nyxx/builders/PermissionsBuilder.dart';
part 'src/nyxx/builders/EmbedBuilder.dart';
part 'src/nyxx/builders/EmbedAuthorBuilder.dart';
part 'src/nyxx/builders/EmbedFieldBuilder.dart';
part 'src/nyxx/builders/EmbedFooterBuilder.dart';
part 'src/nyxx/builders/GuildBuilder.dart';

// OBJECTS

part 'src/nyxx/objects/ISend.dart';
part 'src/nyxx/objects/IMentionable.dart';

part 'src/nyxx/objects/SnowflakeEntity.dart';
part 'src/nyxx/objects/Snowflake.dart';
part 'src/nyxx/objects/Shard.dart';
part 'src/nyxx/objects/Webhook.dart';

part 'src/nyxx/objects/voice/VoiceState.dart';
part 'src/nyxx/objects/voice/VoiceRegion.dart';

part 'src/nyxx/objects/invite/Invite.dart';

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
part 'src/nyxx/objects/guild/Presence.dart';
part 'src/nyxx/objects/guild/Member.dart';
part 'src/nyxx/objects/guild/Status.dart';
part 'src/nyxx/objects/guild/Role.dart';
part 'src/nyxx/objects/guild/User.dart';
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
part 'src/nyxx/objects/permissions/ChannelPermissions.dart';
part 'src/nyxx/objects/permissions/PermissionsConstants.dart';
