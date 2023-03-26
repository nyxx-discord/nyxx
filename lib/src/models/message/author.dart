import 'package:nyxx/src/models/snowflake.dart';

abstract class MessageAuthor {
  Snowflake get id;

  String get username;

  String? get avatarHash;
}
