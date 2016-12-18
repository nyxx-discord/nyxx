library discord;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:w_transport/w_transport.dart' as w_transport;

part 'src/main/Client.dart';

part 'src/main/internal/_Constants.dart';
part 'src/main/internal/_EventController.dart';
part 'src/main/internal/_WS.dart';
part 'src/main/internal/Http.dart';
part 'src/main/internal/Util.dart';

part 'src/main/events/BeforeHttpRequestSendEvent.dart';
part 'src/main/events/ChannelCreateEvent.dart';
part 'src/main/events/ChannelDeleteEvent.dart';
part 'src/main/events/ChannelUpdateEvent.dart';
part 'src/main/events/DisconnectEvent.dart';
part 'src/main/events/GuildBanAddEvent.dart';
part 'src/main/events/GuildBanRemoveEvent.dart';
part 'src/main/events/GuildCreateEvent.dart';
part 'src/main/events/GuildDeleteEvent.dart';
part 'src/main/events/GuildMemberAddEvent.dart';
part 'src/main/events/GuildMemberRemoveEvent.dart';
part 'src/main/events/GuildMemberUpdateEvent.dart';
part 'src/main/events/GuildUnavailableEvent.dart';
part 'src/main/events/GuildUpdateEvent.dart';
part 'src/main/events/HttpErrorEvent.dart';
part 'src/main/events/HttpResponseEvent.dart';
part 'src/main/events/MessageDeleteEvent.dart';
part 'src/main/events/MessageEvent.dart';
part 'src/main/events/MessageUpdateEvent.dart';
part 'src/main/events/PresenceUpdateEvent.dart';
part 'src/main/events/RatelimitEvent.dart';
part 'src/main/events/RawEvent.dart';
part 'src/main/events/ReadyEvent.dart';
part 'src/main/events/RoleCreateEvent.dart';
part 'src/main/events/RoleDeleteEvent.dart';
part 'src/main/events/RoleUpdateEvent.dart';
part 'src/main/events/TypingEvent.dart';

part 'src/main/objects/Attachment.dart';
part 'src/main/objects/Channel.dart';
part 'src/main/objects/ClientOAuth2Application.dart';
part 'src/main/objects/ClientOptions.dart';
part 'src/main/objects/ClientUser.dart';
part 'src/main/objects/DMChannel.dart';
part 'src/main/objects/Embed.dart';
part 'src/main/objects/EmbedProvider.dart';
part 'src/main/objects/EmbedThumbnail.dart';
part 'src/main/objects/Game.dart';
part 'src/main/objects/GroupDMChannel.dart';
part 'src/main/objects/Guild.dart';
part 'src/main/objects/GuildChannel.dart';
part 'src/main/objects/Invite.dart';
part 'src/main/objects/InviteChannel.dart';
part 'src/main/objects/InviteGuild.dart';
part 'src/main/objects/Member.dart';
part 'src/main/objects/Message.dart';
part 'src/main/objects/OAuth2Application.dart';
part 'src/main/objects/OAuth2Guild.dart';
part 'src/main/objects/OAuth2Info.dart';
part 'src/main/objects/Permissions.dart';
part 'src/main/objects/Role.dart';
part 'src/main/objects/Shard.dart';
part 'src/main/objects/TextChannel.dart';
part 'src/main/objects/User.dart';
part 'src/main/objects/VoiceChannel.dart';
part 'src/main/objects/Webhook.dart';

part 'src/main/errors/ClientNotReadyError.dart';
part 'src/main/errors/HttpError.dart';
part 'src/main/errors/InvalidTokenError.dart';
part 'src/main/errors/InvalidShardError.dart';
part 'src/main/errors/NotSetupError.dart';

/// Used internally. DO NOT EDIT THIS
Map<String, dynamic> internals = {
  "setup": false,
  "browser": false,
  "operatingSystem": null,
};
