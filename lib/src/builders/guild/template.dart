import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/guild/template.dart';

class GuildTemplateBuilder extends CreateBuilder<GuildTemplate> {
  final String name;

  final String? description;

  GuildTemplateBuilder({required this.name, this.description});

  @override
  Map<String, Object?> build() => {
        'name': name,
        if (description != null) 'description': description,
      };
}

class GuildTemplateUpdateBuilder extends UpdateBuilder<GuildTemplate> {
  final String? name;

  final String? description;

  GuildTemplateUpdateBuilder({this.name, this.description = sentinelString});

  @override
  Map<String, Object?> build() => {
        if (name != null) 'name': name,
        if (!identical(description, sentinelString)) 'description': description,
      };
}
