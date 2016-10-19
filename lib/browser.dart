library discord;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:collection';
import 'package:http_utils/http_utils.dart' as http_utils;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' as http_browser;
import 'package:args/args.dart' as args;

part 'src/Client.dart';
part 'src/CommandClient.dart';

part 'src/internal/_BaseObj.dart';
part 'src/internal/_Constants.dart';
part 'src/internal/_EventController.dart';
part 'src/internal/_Http.dart';
part 'src/internal/_Util.dart';
part 'src/internal/_WS.dart';

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
part 'src/objects/MessageOptions.dart';
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

final bool _browser = true;

class _WebSocket {
  html.WebSocket _socket;

  _WebSocket();

  Future<_WebSocket> connect(
      String url, void onData(dynamic data), void onDone(int closeCode)) async {
    this._socket = new html.WebSocket(url);
    this._socket.onMessage.listen((html.MessageEvent e) {
      onData(e.data);
    });
    this._socket.onClose.listen((html.CloseEvent e) {
      onData(e.code);
    });
    return this;
  }

  void send(dynamic data) {
    this._socket.send(data);
  }

  Future close([int code]) async {
    this._socket.close(code);
  }
}

class _HttpClient {
  http_browser.BrowserClient client;

  _HttpClient() {
    this.client = new http_browser.BrowserClient();
  }

  void close() => this.client.close();

  Future<http.Response> get(String url, {Map<String, String> headers}) async =>
      await this.client.get(url, headers: headers);

  Future<http.Response> post(String url,
          {dynamic body, Map<String, String> headers}) async =>
      await this.client.post(url, body: body, headers: headers);

  Future<http.Response> put(String url,
          {dynamic body, Map<String, String> headers}) async =>
      await this.client.put(url, body: body, headers: headers);

  Future<http.Response> patch(String url,
          {dynamic body, Map<String, String> headers}) async =>
      await this.client.patch(url, body: body, headers: headers);

  Future<http.Response> delete(String url,
          {Map<String, String> headers}) async =>
      await this.client.delete(url, headers: headers);
}
