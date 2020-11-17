/// Nyxx Discord API wrapper for Dart
///
/// Main library which contains all stuff needed to connect and interact with Discord API.
library nyxx;

import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:isolate"; // Used to discard errors on vm to continue working even if error occurred

import "package:logging/logging.dart";
import "package:http/http.dart" as http;
import "package:path/path.dart" as path_utils;

// BASE

part "src/Nyxx.dart";
part "src/ClientOptions.dart";

// INTERNAL

part "src/internal/exceptions/MissingTokenError.dart";
part "src/internal/exceptions/EmbedBuilderArgumentException.dart";
part "src/internal/exceptions/InvalidShardException.dart";
part "src/internal/exceptions/InvalidSnowflakeException.dart";
part "src/internal/exceptions/HttpClientException.dart";

part "src/internal/shard/Shard.dart";
part "src/internal/shard/ShardManager.dart";
part "src/internal/shard/shardHandler.dart";

part "src/internal/_Constants.dart";
part "src/internal/_EventController.dart";
part "src/internal/_ConnectionManager.dart";
part "src/internal/_HttpEndpoints.dart";

part "src/internal/http/_HttpClient.dart";
part "src/internal/http/HttpBucket.dart";

part "src/internal/cache/Cache.dart";
part "src/internal/cache/_SnowflakeCache.dart";
part "src/internal/cache/ChannelCache.dart";
part "src/internal/cache/MessageCache.dart";
part "src/internal/cache/Cacheable.dart";

part "src/internal/http/HttpHandler.dart";
part "src/internal/http/HttpRequest.dart";
part "src/internal/http/HttpResponse.dart";

part "src/internal/interfaces/Disposable.dart";
part "src/internal/interfaces/IMessageAuthor.dart";
part "src/internal/interfaces/Convertable.dart";
part "src/internal/interfaces/ISend.dart";
part "src/internal/interfaces/Mentionable.dart";

// EVENTS

part "src/events/MemberChunkEvent.dart";

part "src/events/DisconnectEvent.dart";
part "src/events/PresenceUpdateEvent.dart";
part "src/events/RatelimitEvent.dart";
part "src/events/ReadyEvent.dart";
part "src/events/TypingEvent.dart";

part "src/events/VoiceServerUpdateEvent.dart";
part "src/events/VoiceStateUpdateEvent.dart";
part "src/events/UserUpdateEvent.dart";

part "src/events/MessageEvents.dart";
part "src/events/HttpEvents.dart";
part "src/events/ChannelEvents.dart";
part "src/events/GuildEvents.dart";

part "src/events/InviteEvents.dart";

// BUILDERS

part "src/utils/builders/Builder.dart";

part "src/utils/builders/ReplyBuilder.dart";
part "src/utils/builders/PresenceBuilder.dart";
part "src/utils/builders/AttachmentBuilder.dart";
part "src/utils/builders/PermissionsBuilder.dart";
part "src/utils/builders/EmbedBuilder.dart";
part "src/utils/builders/EmbedAuthorBuilder.dart";
part "src/utils/builders/EmbedFieldBuilder.dart";
part "src/utils/builders/EmbedFooterBuilder.dart";
part "src/utils/builders/GuildBuilder.dart";
part "src/utils/builders/MessageBuilder.dart";

part "src/utils/extensions.dart";

// OBJECTS

part "src/core/AllowedMentions.dart";

part "src/core/DiscordColor.dart";

part "src/core/SnowflakeEntity.dart";
part "src/core/Snowflake.dart";
part "src/core/guild/Webhook.dart";

part "src/core/voice/VoiceState.dart";
part "src/core/voice/VoiceRegion.dart";

part "src/core/Invite.dart";

part "src/core/auditlogs/AuditLog.dart";
part "src/core/auditlogs/AuditLogEntry.dart";
part "src/core/auditlogs/AuditLogChange.dart";

part "src/core/channel/guild/CategoryGuildChannel.dart";
part "src/core/channel/guild/GuildChannel.dart";
part "src/core/channel/guild/TextGuildChannel.dart";
part "src/core/channel/guild/VoiceChannel.dart";
part "src/core/channel/Channel.dart";
part "src/core/channel/DMChannel.dart";
part "src/core/channel/TextChannel.dart";

part "src/core/embed/EmbedField.dart";
part "src/core/embed/EmbedAuthor.dart";
part "src/core/embed/EmbedFooter.dart";
part "src/core/embed/EmbedVideo.dart";
part "src/core/embed/Embed.dart";
part "src/core/embed/EmbedProvider.dart";
part "src/core/embed/EmbedThumbnail.dart";

part "src/core/guild/ClientUser.dart";
part "src/core/guild/Guild.dart";
part "src/core/guild/GuildFeature.dart";
part "src/core/user/Presence.dart";
part "src/core/user/Member.dart";
part "src/core/guild/Status.dart";
part "src/core/guild/Role.dart";
part "src/core/user/User.dart";
part "src/core/user/UserFlags.dart";
part "src/core/user/NitroType.dart";
part "src/core/guild/Ban.dart";
part "src/core/guild/PremiumTier.dart";
part "src/core/guild/GuildPreview.dart";

part "src/core/message/UnicodeEmoji.dart";
part "src/core/message/GuildEmoji.dart";
part "src/core/message/Emoji.dart";
part "src/core/message/Reaction.dart";
part "src/core/message/Message.dart";
part "src/core/message/Sticker.dart";
part "src/core/message/Attachment.dart";
part "src/core/message/MessageFlags.dart";
part "src/core/message/MessageReference.dart";
part "src/core/message/MessageType.dart";
part "src/core/message/ReferencedMessage.dart";

part "src/core/application/ClientOAuth2Application.dart";
part "src/core/application/OAuth2Application.dart";
part "src/core/application/OAuth2Guild.dart";
part "src/core/application/OAuth2Info.dart";
part "src/core/application/AppTeam.dart";

part "src/core/permissions/Permissions.dart";
part "src/core/permissions/PermissionOverrides.dart";
part "src/core/permissions/PermissionsConstants.dart";

part "src/utils/permissions.dart";
part "src/utils/utils.dart";
part "src/utils/IEnum.dart";
