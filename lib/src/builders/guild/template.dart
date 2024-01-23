import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/guild/template.dart';

class GuildTemplateBuilder extends CreateBuilder<GuildTemplate> {
  String name;

  String? description;

  GuildTemplateBuilder({required this.name, this.description = sentinelString});

  @override
  Map<String, Object?> build() => {
        if (!identical(description, sentinelString)) 'name': name,
        if (description != null) 'description': description,
      };
}

class GuildTemplateUpdateBuilder extends UpdateBuilder<GuildTemplate> {
  String? name;

  String? description;

  GuildTemplateUpdateBuilder({this.name, this.description = sentinelString});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(description, sentinelString)) 'description': description,
      };
}
