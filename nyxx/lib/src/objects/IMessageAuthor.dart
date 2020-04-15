part of nyxx;

//TODO: Consider what should be here and what should not
abstract class IMessageAuthor implements SnowflakeEntity {
  String get username;
  int get discriminator;
  bool get bot;
  String get tag;

  String? avatarURL({String format = 'webp', int size = 128});
}