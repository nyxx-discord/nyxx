import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/events/ready_event.dart';
import 'package:nyxx/src/internal/event_controller.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';
import 'package:nyxx/src/internal/http/http_response.dart';
import 'package:nyxx/src/internal/shard/shard_manager.dart';

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
  ConnectionManager(this.client);

  Future<void> connect() async {
    final httpResponse = await (client.httpEndpoints as HttpEndpoints).getGatewayBot();

    if (httpResponse is HttpResponseError) {
      throw UnrecoverableNyxxError("Cannot get gateway url: [${httpResponse.errorCode}; ${httpResponse.errorMessage}]");
    }

    final response = httpResponse as HttpResponseSuccess;

    gateway = response.jsonBody["url"] as String;
    remaining = response.jsonBody["session_start_limit"]["remaining"] as int;
    resetAt = DateTime.now().add(Duration(milliseconds: response.jsonBody["session_start_limit"]["reset_after"] as int));
    recommendedShardsNum = response.jsonBody["shards"] as int;
    maxConcurrency = response.jsonBody["session_start_limit"]["max_concurrency"] as int;

    _logger.fine("Got gateway info: Url: [$gateway]; Recommended shard num: [$recommendedShardsNum]");

    checkForConnections();

    client.shardManager = ShardManager(this, maxConcurrency);
  }

  void checkForConnections() {
    _logger.info("Remaining $remaining connections starts. Limit will reset at $resetAt");

    if (remaining < 50) {
      _logger.warning("50 connection starts left.");
    }

    if (remaining < 10) {
      _logger.severe("Exiting to prevent API abuse. 10 connections starts left.");
      throw UnrecoverableNyxxError('Exiting nyxx to prevent API ban. Remaining less that 10 connection to gateway');
    }
  }

  Future<void> propagateReady() async {
    _shardsReady++;
    if (client.ready || _shardsReady < (client.options.shardCount ?? 1)) {
      return;
    }

    if (!client.ready) {
      (client.eventsWs as WebsocketEventController).onReadyController.add(ReadyEvent(client));
    }
    client.ready = true;
    _logger.info("Connected and ready! Logged as `${client.self.tag}`");
  }
}
