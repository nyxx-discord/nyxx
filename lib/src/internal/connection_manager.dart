import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/application/client_oauth2_application.dart';
import 'package:nyxx/src/events/ready_event.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';
import 'package:nyxx/src/internal/http/http_response.dart';
import 'package:nyxx/src/internal/shard/shard_manager.dart';
import 'package:nyxx/src/typedefs.dart';

/// The WS manager for the client.
class ConnectionManager {
  final NyxxWebsocket client;

  /// The base websocket URL.
  late final String gateway;

  late final int remaining;
  late final DateTime resetAt;
  late final int recommendedShardsNum;
  late final int maxConcurrency;

  final Logger _logger = Logger("Client");

  int _shardsReady = 0;

  /// Makes a new WS manager.
  ConnectionManager(this.client) {
    (client.httpEndpoints as HttpEndpoints).getGatewayBot().then((httpResponse) {
      if (httpResponse is HttpResponseError) {
        this._logger.severe("Cannot get gateway url: [${httpResponse.errorCode}; ${httpResponse.errorMessage}]");
        exit(1);
      }

      final response = httpResponse as HttpResponseSuccess;

      this.gateway = response.jsonBody["url"] as String;
      this.remaining = response.jsonBody["session_start_limit"]["remaining"] as int;
      this.resetAt = DateTime.now().add(Duration(milliseconds: response.jsonBody["session_start_limit"]["reset_after"] as int));
      this.recommendedShardsNum = response.jsonBody["shards"] as int;
      this.maxConcurrency = response.jsonBody["session_start_limit"]["max_concurrency"] as int;

      this._logger.fine("Got gateway info: Url: [$gateway]; Recommended shard num: [$recommendedShardsNum]");

      checkForConnections();

      this.client.shardManager = ShardManager(this, this.maxConcurrency);
    });
  }

  void checkForConnections() {
    _logger.info("Remaining ${this.remaining} connections starts. Limit will reset at ${this.resetAt}");

    if (this.remaining < 50) {
      _logger.warning("50 connection starts left.");
    }

    if (this.remaining < 10) {
      _logger.severe("Exiting to prevent API abuse. 10 connections starts left.");
      exit(1);
    }
  }

  Future<void> propagateReady() async {
    this._shardsReady++;
    if (client.ready || this._shardsReady < (client.options.shardCount ?? 1)) {
      return;
    }

    final httpResponse = await (client.httpEndpoints as HttpEndpoints).getMeApplication();

    if (httpResponse is HttpResponseError) {
      this._logger.shout("Cannot get bot identity: `${httpResponse.toString()}`");
      exit(1);
    }

    final response = httpResponse as HttpResponseSuccess;
    client.app = ClientOAuth2Application(response.jsonBody as RawApiMap, client);

    if (!client.ready) {
      (client.eventsWs as WebsocketEventController).onReadyController.add(ReadyEvent(client));
    }
    client.ready = true;
    _logger.info("Connected and ready! Logged as `${client.self.tag}`");
  }
}
