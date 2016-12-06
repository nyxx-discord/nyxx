library discord;

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:args/args.dart' as args;
import 'package:w_transport/w_transport.dart' as w_transport;

part 'src/Client.dart';
part 'src/CommandClient.dart';

part 'src/internal/_Constants.dart';
part 'src/internal/_EventController.dart';
part 'src/internal/_WS.dart';
part 'src/internal/Http.dart';
part 'src/internal/Util.dart';

part 'src/events/ChannelCreateEvent.dart';
part 'src/events/ChannelDeleteEvent.dart';
part 'src/events/ChannelUpdateEvent.dart';
part 'src/events/GuildBanAddEvent.dart';
part 'src/events/GuildBanRemoveEvent.dart';
part 'src/events/GuildCreateEvent.dart';
part 'src/events/GuildDeleteEvent.dart';
part 'src/events/GuildMemberAddEvent.dart';
part 'src/events/GuildMemberRemoveEvent.dart';
part 'src/events/GuildMemberUpdateEvent.dart';
part 'src/events/GuildUnavailableEvent.dart';
part 'src/events/GuildUpdateEvent.dart';
part 'src/events/MessageDeleteEvent.dart';
part 'src/events/MessageEvent.dart';
part 'src/events/MessageUpdateEvent.dart';
part 'src/events/PresenceUpdateEvent.dart';
part 'src/events/RawEvent.dart';
part 'src/events/ReadyEvent.dart';
part 'src/events/RoleCreateEvent.dart';
part 'src/events/RoleDeleteEvent.dart';
part 'src/events/RoleUpdateEvent.dart';
part 'src/events/TypingEvent.dart';

part 'src/objects/Argument.dart';
part 'src/objects/Attachment.dart';
part 'src/objects/Channel.dart';
part 'src/objects/ClientOAuth2Application.dart';
part 'src/objects/ClientOptions.dart';
part 'src/objects/ClientUser.dart';
part 'src/objects/Command.dart';
part 'src/objects/DMChannel.dart';
part 'src/objects/Embed.dart';
part 'src/objects/EmbedProvider.dart';
part 'src/objects/EmbedThumbnail.dart';
part 'src/objects/Game.dart';
part 'src/objects/GroupDMChannel.dart';
part 'src/objects/Guild.dart';
part 'src/objects/GuildChannel.dart';
part 'src/objects/Invite.dart';
part 'src/objects/InviteChannel.dart';
part 'src/objects/InviteGuild.dart';
part 'src/objects/Member.dart';
part 'src/objects/Message.dart';
part 'src/objects/OAuth2Application.dart';
part 'src/objects/OAuth2Guild.dart';
part 'src/objects/OAuth2Info.dart';
part 'src/objects/Permissions.dart';
part 'src/objects/Role.dart';
part 'src/objects/Shard.dart';
part 'src/objects/TextChannel.dart';
part 'src/objects/User.dart';
part 'src/objects/VoiceChannel.dart';
part 'src/objects/Webhook.dart';

part 'src/errors/ClientNotReadyError.dart';
part 'src/errors/HttpError.dart';
part 'src/errors/InvalidTokenError.dart';
part 'src/errors/InvalidShardError.dart';
part 'src/errors/NotSetupError.dart';

/// Used internally. DO NOT EDIT IT'S VALUE.
bool setup = false;
