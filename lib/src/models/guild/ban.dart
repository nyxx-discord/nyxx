import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

class Ban with ToStringHelper {
  final String? reason;

  final User user;

  Ban({required this.reason, required this.user});
}
