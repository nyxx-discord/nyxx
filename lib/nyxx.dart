/// Nyxx DISCORD API wrapper for Dart
///
/// Library consists of 2 modules [nyxx] and [nyxx.commands].
///
/// This module (aka library) contains all main nyxx logic:
///
///  - `/internal` - contains internal things like Http and Websocket stack needed for library to work
///  - `/` - root path has generic models/objects/stuff which is used everywhere
///  - `/builders` - contains classes used to build [Embed]s
///  - `/objects` - directory which groups all data classes
///  - `/events` - classes used in event dispatching
///  - `/errors` - Few errors to report weird behavior
library nyxx;

import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';
import 'dart:collection';
import 'dart:io';

//import 'src/internals.dart' as internals;

import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:w_transport/w_transport.dart' as w_transport;
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:logging/logging.dart';

part 'src/internal/_Constants.dart';
part 'src/internal/_EventController.dart';
part 'src/internal/_WS.dart';
part 'src/internal/Http.dart';
part 'src/internal/Util.dart';

part 'src/objects/auditlogs/AuditLog.dart';
part 'src/objects/auditlogs/AuditLogEntry.dart';
part 'src/objects/auditlogs/AuditLogChange.dart';

part 'src/Client.dart';
part 'src/objects/Snowflake.dart';

part 'src/builders/EmbedBuilder.dart';
part 'src/builders/EmbedAuthorBuilder.dart';
part 'src/builders/EmbedFieldBuilder.dart';
part 'src/builders/EmbedFooterBuilder.dart';
part 'src/builders/EmbedProviderBuilder.dart';
part 'src/builders/PermissionsBuilder.dart';

part 'src/objects/embed/EmbedField.dart';
part 'src/objects/embed/EmbedAuthor.dart';
part 'src/objects/embed/EmbedFooter.dart';
part 'src/objects/embed/EmbedVideo.dart';
part 'src/objects/embed/Embed.dart';
part 'src/objects/embed/EmbedProvider.dart';
part 'src/objects/embed/EmbedThumbnail.dart';

part 'src/events/BeforeHttpRequestSendEvent.dart';
part 'src/events/ChannelCreateEvent.dart';
part 'src/events/ChannelDeleteEvent.dart';
part 'src/events/ChannelUpdateEvent.dart';
part 'src/events/DisconnectEvent.dart';
part 'src/events/GuildBanAddEvent.dart';
part 'src/events/GuildBanRemoveEvent.dart';
part 'src/events/GuildCreateEvent.dart';
part 'src/events/GuildDeleteEvent.dart';
part 'src/events/GuildMemberAddEvent.dart';
part 'src/events/GuildMemberRemoveEvent.dart';
part 'src/events/GuildMemberUpdateEvent.dart';
part 'src/events/GuildUnavailableEvent.dart';
part 'src/events/GuildUpdateEvent.dart';
part 'src/events/HttpErrorEvent.dart';
part 'src/events/HttpResponseEvent.dart';
part 'src/events/MessageDeleteEvent.dart';
part 'src/events/MessageEvent.dart';
part 'src/events/MessageUpdateEvent.dart';
part 'src/events/PresenceUpdateEvent.dart';
part 'src/events/RatelimitEvent.dart';
part 'src/events/RawEvent.dart';
part 'src/events/ReadyEvent.dart';
part 'src/events/RoleCreateEvent.dart';
part 'src/events/RoleDeleteEvent.dart';
part 'src/events/RoleUpdateEvent.dart';
part 'src/events/TypingEvent.dart';
part 'src/events/ChannelPinsUpdateEvent.dart';
part 'src/events/GuildEmojisUpdateEvent.dart';
part 'src/events/MessageDeleteBulkEvent.dart';
part 'src/events/MessageReactionEvent.dart';
part 'src/events/MessageReactionsRemovedEvent.dart';
part 'src/events/VoiceServerUpdateEvent.dart';
part 'src/events/VoiceStateUpdateEvent.dart';
part 'src/events/WebhookUpdateEvent.dart';

part 'src/objects/VoiceState.dart';

part 'src/objects/message/UnicodeEmoji.dart';
part 'src/objects/message/GuildEmoji.dart';
part 'src/objects/message/Emoji.dart';
part 'src/objects/message/EmojisUnicode.dart';
part 'src/objects/message/Reaction.dart';
part 'src/objects/message/Message.dart';
part 'src/objects/message/Attachment.dart';

part 'src/objects/channel/VoiceChannel.dart';
part 'src/objects/channel/GroupChannel.dart';
part 'src/objects/channel/TextChannel.dart';
part 'src/objects/channel/GuildChannel.dart';
part 'src/objects/channel/GroupDMChannel.dart';
part 'src/objects/channel/DMChannel.dart';
part 'src/objects/channel/Channel.dart';
part 'src/objects/channel/MessageChannel.dart';

part 'src/objects/VoiceRegion.dart';
part 'src/objects/ClientOAuth2Application.dart';
part 'src/objects/ClientOptions.dart';
part 'src/objects/ClientUser.dart';
part 'src/objects/Game.dart';
part 'src/objects/Guild.dart';
part 'src/objects/Invite.dart';
part 'src/objects/InviteChannel.dart';
part 'src/objects/InviteGuild.dart';
part 'src/objects/Member.dart';
part 'src/objects/OAuth2Application.dart';
part 'src/objects/OAuth2Guild.dart';
part 'src/objects/OAuth2Info.dart';
part 'src/objects/Permissions.dart';
part 'src/objects/Role.dart';
part 'src/objects/Shard.dart';
part 'src/objects/User.dart';
part 'src/objects/Webhook.dart';
part 'src/objects/AbstractPermissions.dart';
part 'src/objects/ChannelPermissions.dart';
part 'src/objects/PermissionsConstants.dart';

part 'src/errors/HttpError.dart';