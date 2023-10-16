import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/gateway/events/presence.dart';
import 'package:nyxx/src/models/presence.dart';

class PresenceBuilder extends CreateBuilder<PresenceUpdateEvent> {
  DateTime? since;

  List<ActivityBuilder>? activities;

  CurrentUserStatus status;

  bool isAfk;

  PresenceBuilder({this.since, this.activities, required this.status, required this.isAfk});

  @override
  Map<String, Object?> build() => {
        'since': since?.millisecondsSinceEpoch,
        'activities': activities?.map((e) => e.build()).toList(),
        'status': status.value,
        'afk': isAfk,
      };
}

enum CurrentUserStatus {
  online._('online'),
  dnd._('dnd'),
  idle._('idle'),
  invisible._('invisible'),
  offline._('offline');

  final String value;

  const CurrentUserStatus._(this.value);

  @override
  String toString() => 'CurrentUserStatus($value)';
}

class ActivityBuilder extends CreateBuilder<Activity> {
  String name;

  String? state;

  ActivityType type;

  Uri? url;

  ActivityBuilder({required this.name, required this.type, this.state, this.url});

  @override
  Map<String, Object?> build() => {
        'name': name,
        'type': type.value,
        if (state != null) 'state': state!,
        if (url != null) 'url': url!.toString(),
      };
}
