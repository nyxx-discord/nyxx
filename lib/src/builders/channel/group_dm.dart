import 'dart:convert';

import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/models/channel/types/group_dm.dart';

class GroupDmUpdateBuilder extends UpdateBuilder<GroupDmChannel> {
  String? name;

  List<int>? icon;

  GroupDmUpdateBuilder({this.name, this.icon});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (icon != null) 'icon': base64Encode(icon!),
      };
}
