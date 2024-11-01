import 'dart:convert';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/types/group_dm.dart';

class GroupDmUpdateBuilder extends UpdateBuilder<GroupDmChannel> {
  /// The name of the group DM, if changed.
  String? name;

  /// The icon, if changed.
  List<int>? icon;

  GroupDmUpdateBuilder({this.name, this.icon});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (icon != null) 'icon': base64Encode(icon!),
      };
}

class DmRecipientBuilder extends CreateBuilder<DmRecipientBuilder> {
  String accessToken;

  String nick;

  DmRecipientBuilder({required this.accessToken, required this.nick});

  @override
  Map<String, Object?> build() => {
        'access_token': accessToken,
        'nick': nick,
      };
}
