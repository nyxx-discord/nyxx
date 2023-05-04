import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// {@template followed_channel}
/// Information about a channel which has been followed.
/// {@endtemplate}
class FollowedChannel with ToStringHelper {
  /// The ID of the channel that has been followed.
  final Snowflake channelId;

  /// The ID of the webhook created in the subscriber channel.
  final Snowflake webhookId;

  /// {@macro followed_channel}
  FollowedChannel({required this.channelId, required this.webhookId});
}
