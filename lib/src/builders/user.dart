import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/models/user/user.dart';

class UserUpdateBuilder extends UpdateBuilder<User> {
  final String? username;
  final ImageBuilder? avatar;

  const UserUpdateBuilder({this.username, this.avatar});

  @override
  Map<String, Object?> build() => {
        if (username != null) 'username': username!,
        if (avatar != null) 'avatar': avatar!.build(),
      };
}
