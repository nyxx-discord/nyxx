import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/models/gateway/event.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/user/user.dart';

class ReadyEvent extends DispatchEvent {
  final int version;

  final User user;

  final List<PartialGuild> guilds;

  final String sessionId;

  final Uri gatewayResumeUrl;

  final int? shardId;

  final int? totalShards;

  final PartialApplication application;

  ReadyEvent({
    required this.version,
    required this.user,
    required this.guilds,
    required this.sessionId,
    required this.gatewayResumeUrl,
    required this.shardId,
    required this.totalShards,
    required this.application,
  });
}

class ResumedEvent extends DispatchEvent {}
