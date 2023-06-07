import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class ClientStatus with ToStringHelper {
  final UserStatus? desktop;

  final UserStatus? mobile;

  final UserStatus? web;

  ClientStatus({required this.desktop, required this.mobile, required this.web});
}

enum UserStatus {
  online._('online'),
  idle._('idle'),
  dnd._('dnd');

  final String value;

  const UserStatus._(this.value);

  factory UserStatus.parse(String value) => UserStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => throw FormatException('Unknown user status', value),
      );

  @override
  String toString() => 'UserStatus($value)';
}

class Activity with ToStringHelper {
  final String name;

  final ActivityType type;

  final Uri? url;

  final DateTime? createdAt;

  final ActivityTimestamps? timestamps;

  final Snowflake? applicationId;

  final String? details;

  final String? state;

  // TODO
  //final Emoji? emoji;

  final ActivityParty? party;

  final ActivityAssets? assets;

  final ActivitySecrets? secrets;

  final bool? isInstance;

  final ActivityFlags? flags;

  final List<ActivityButton>? buttons;

  Activity({
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.timestamps,
    required this.applicationId,
    required this.details,
    required this.state,
    required this.party,
    required this.assets,
    required this.secrets,
    required this.isInstance,
    required this.flags,
    required this.buttons,
  });
}

enum ActivityType {
  game._(0),
  streaming._(1),
  listening._(2),
  watching._(3),
  custom._(4),
  competing._(5);

  final int value;

  const ActivityType._(this.value);

  factory ActivityType.parse(int value) => ActivityType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown activity type', value),
      );

  @override
  String toString() => 'ActivityType($value)';
}

class ActivityTimestamps with ToStringHelper {
  final DateTime? start;

  final DateTime? end;

  ActivityTimestamps({required this.start, required this.end});
}

class ActivityParty with ToStringHelper {
  final String? id;

  final int? currentSize;

  final int? maxSize;

  ActivityParty({required this.id, required this.currentSize, required this.maxSize});
}

class ActivityAssets with ToStringHelper {
  // TODO: Make a proper class for this, or parse it to e.g a Uri
  final String? largeImage;

  final String? largeText;

  // TODO: See above
  final String? smallImage;

  final String? smallText;

  ActivityAssets({
    required this.largeImage,
    required this.largeText,
    required this.smallImage,
    required this.smallText,
  });
}

class ActivitySecrets with ToStringHelper {
  final String? join;

  final String? spectate;

  final String? match;

  ActivitySecrets({required this.join, required this.spectate, required this.match});
}

class ActivityFlags extends Flags<ActivityFlags> {
  static const instance = Flag<ActivityFlags>.fromOffset(0);
  static const canJoin = Flag<ActivityFlags>.fromOffset(1);
  static const spectate = Flag<ActivityFlags>.fromOffset(2);
  static const joinRequest = Flag<ActivityFlags>.fromOffset(3);
  static const sync = Flag<ActivityFlags>.fromOffset(4);
  static const play = Flag<ActivityFlags>.fromOffset(5);
  static const partyPrivacyFriends = Flag<ActivityFlags>.fromOffset(6);
  static const partyPrivacyVoiceChannel = Flag<ActivityFlags>.fromOffset(7);
  static const embedded = Flag<ActivityFlags>.fromOffset(8);

  ActivityFlags(super.value);

  bool get hasInstance => has(instance);
  bool get hasCanJoin => has(canJoin);
  bool get hasSpectate => has(spectate);
  bool get hasJoinRequest => has(joinRequest);
  bool get hasSync => has(sync);
  bool get hasPlay => has(play);
  bool get hasPartyPrivacyFriends => has(partyPrivacyFriends);
  bool get hasPartyPrivacyVoiceChannel => has(partyPrivacyVoiceChannel);
  bool get isEmbedded => has(embedded);
}

class ActivityButton with ToStringHelper {
  final String label;

  final Uri url;

  ActivityButton({required this.label, required this.url});
}
