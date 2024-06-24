import 'package:nyxx/src/models/emoji.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/enum_like.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template client_status}
/// The status of a client on multiple platforms.
/// {@endtemplate}
class ClientStatus with ToStringHelper {
  /// The client's status on a desktop session.
  final UserStatus? desktop;

  /// The client's status on a mobile session.
  final UserStatus? mobile;

  /// The client's status on a web session, or a bot client's status.
  final UserStatus? web;

  /// {@macro client_status}
  /// @nodoc
  ClientStatus({required this.desktop, required this.mobile, required this.web});
}

/// The status of a client.
final class UserStatus extends EnumLike<String, UserStatus> {
  static const online = UserStatus('online');
  static const dnd = UserStatus('dnd');
  static const idle = UserStatus('idle');
  static const offline = UserStatus('offline');

  /// @nodoc
  const UserStatus(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  UserStatus.parse(String value) : this(value);
}

/// {@template activity}
/// A Rich Presence activity.
/// {@endtemplate}
class Activity with ToStringHelper {
  /// The name of this activity.
  final String name;

  /// The type of this activity.
  final ActivityType type;

  /// The URL to this activity.
  final Uri? url;

  /// The time at which this activity was started.
  final DateTime? createdAt;

  /// Information about this activity's timing.
  final ActivityTimestamps? timestamps;

  /// The ID of the application associated with this activity.
  final Snowflake? applicationId;

  /// Additional details about the current activity state.
  final String? details;

  /// The current state of this activity.
  final String? state;

  /// The custom emoji for this activity.
  final Emoji? emoji;

  /// Information about this activity's party.
  final ActivityParty? party;

  /// Assets to use when displaying this activity.
  final ActivityAssets? assets;

  /// Rich presence secrets associated with this activity.
  final ActivitySecrets? secrets;

  /// Whether this activity is an instanced game session.
  final bool? isInstance;

  /// Flags indicating which fields this activity has.
  final ActivityFlags? flags;

  /// A list of buttons displayed with the activity.
  final List<ActivityButton>? buttons;

  /// {@macro activity}
  /// @nodoc
  Activity({
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.timestamps,
    required this.applicationId,
    required this.details,
    required this.state,
    required this.emoji,
    required this.party,
    required this.assets,
    required this.secrets,
    required this.isInstance,
    required this.flags,
    required this.buttons,
  });
}

/// The type of an activity.
final class ActivityType extends EnumLike<int, ActivityType> {
  static const game = ActivityType(0);
  static const streaming = ActivityType(1);
  static const listening = ActivityType(2);
  static const watching = ActivityType(3);
  static const custom = ActivityType(4);
  static const competing = ActivityType(5);

  const ActivityType(super.value);

  @Deprecated('The .parse() constructor is deprecated. Use the unnamed constructor instead.')
  ActivityType.parse(int value) : this(value);
}

/// {@template activity_timestamps}
/// Information about an [Activity]'s timings.
/// {@endtemplate}
class ActivityTimestamps with ToStringHelper {
  /// The time at which the activity starts.
  final DateTime? start;

  /// The time at which the activity ends.
  final DateTime? end;

  /// {@macro activity_timestamps}
  /// @nodoc
  ActivityTimestamps({required this.start, required this.end});
}

/// {@template activity_party}
/// Information about an [Activity]'s party.
/// {@endtemplate}
class ActivityParty with ToStringHelper {
  /// The ID of the party.
  final String? id;

  /// The current size of the party.
  final int? currentSize;

  /// The maximum size of the party.
  final int? maxSize;

  /// {@macro activity_party}
  /// @nodoc
  ActivityParty({required this.id, required this.currentSize, required this.maxSize});
}

/// {@template activity_assets}
/// Information about an [Activity]'s displayed assets.
/// {@endtemplate}
class ActivityAssets with ToStringHelper {
  /// The activity's large image.
  // TODO: Make a proper class for this, or parse it to e.g a Uri
  final String? largeImage;

  /// The text displayed when hovering over the large image.
  final String? largeText;

  /// The activity's small image.
  // TODO: See above
  final String? smallImage;

  /// The test displayed when hovering over the small image.
  final String? smallText;

  /// {@macro activity_assets}
  /// @nodoc
  ActivityAssets({
    required this.largeImage,
    required this.largeText,
    required this.smallImage,
    required this.smallText,
  });
}

/// {@template activity_secrets}
/// Information about an [Activity]'s secrets.
/// {@endtemplate}
class ActivitySecrets with ToStringHelper {
  /// The join secret.
  final String? join;

  /// The spectate secret.
  final String? spectate;

  /// The match secret.
  final String? match;

  /// {@macro activity_secrets}
  /// @nodoc
  ActivitySecrets({required this.join, required this.spectate, required this.match});
}

/// Information about the data in an [Activity] instance.
class ActivityFlags extends Flags<ActivityFlags> {
  /// The activity is an instanced game session.
  static const instance = Flag<ActivityFlags>.fromOffset(0);

  /// The activity can be joined.
  static const canJoin = Flag<ActivityFlags>.fromOffset(1);

  /// The activity can be spectated.
  static const spectate = Flag<ActivityFlags>.fromOffset(2);

  /// The client can request to join the activity.
  static const joinRequest = Flag<ActivityFlags>.fromOffset(3);
  static const sync = Flag<ActivityFlags>.fromOffset(4);
  static const play = Flag<ActivityFlags>.fromOffset(5);
  static const partyPrivacyFriends = Flag<ActivityFlags>.fromOffset(6);
  static const partyPrivacyVoiceChannel = Flag<ActivityFlags>.fromOffset(7);
  static const embedded = Flag<ActivityFlags>.fromOffset(8);

  /// Create a new [ActivityFlags].
  ActivityFlags(super.value);

  /// Whether this [ActivityFlags] has the [instance] flag set.
  bool get hasInstance => has(instance);

  /// Whether this [ActivityFlags] has the [canJoin] flag set.
  bool get hasCanJoin => has(canJoin);

  /// Whether this [ActivityFlags] has the [spectate] flag set.
  bool get hasSpectate => has(spectate);

  /// Whether this [ActivityFlags] has the [joinRequest] flag set.
  bool get hasJoinRequest => has(joinRequest);

  /// Whether this [ActivityFlags] has the [sync] flag set.
  bool get hasSync => has(sync);

  /// Whether this [ActivityFlags] has the [play] flag set.
  bool get hasPlay => has(play);

  /// Whether this [ActivityFlags] has the [partyPrivacyFriends] flag set.
  bool get hasPartyPrivacyFriends => has(partyPrivacyFriends);

  /// Whether this [ActivityFlags] has the [partyPrivacyVoiceChannel] flag set.
  bool get hasPartyPrivacyVoiceChannel => has(partyPrivacyVoiceChannel);

  /// Whether this [ActivityFlags] has the [embedded] flag set.
  bool get isEmbedded => has(embedded);
}

/// {@template activity_button}
/// A button displayed in an activity.
/// {@endtemplate}
class ActivityButton with ToStringHelper {
  /// This button's label.
  final String label;

  /// The URL opened when this button is clicked.
  final Uri url;

  /// {@macro activity_button}
  /// @nodoc
  ActivityButton({required this.label, required this.url});
}
