import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class FollowedChannel with ToStringHelper {
  final Snowflake channelId;

  final Snowflake webhookId;

  FollowedChannel({required this.channelId, required this.webhookId});
}
