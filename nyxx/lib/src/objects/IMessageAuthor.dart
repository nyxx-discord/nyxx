part of nyxx;

//TODO: Consider what should be here and what should not
abstract class IMessageAuthor implements SnowflakeEntity {
  String get username;

  String? avatarURL({String format = 'webp', int size = 128});
}