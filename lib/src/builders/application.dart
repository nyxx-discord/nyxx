import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/utils/flags.dart';

class ApplicationUpdateBuilder extends UpdateBuilder<Application> {
  Uri? customInstallUrl;

  String? description;

  Uri? roleConnectionsVerificationUrl;

  InstallationParameters? installationParameters;

  Flags<ApplicationFlags>? flags;

  ImageBuilder? icon;

  ImageBuilder? coverImage;

  Uri? interactionsEndpointUrl;

  List<String>? tags;

  Map<ApplicationIntegrationType, ApplicationIntegrationTypeConfiguration>? integrationTypesConfig;

  ApplicationUpdateBuilder({
    this.customInstallUrl,
    this.description,
    this.roleConnectionsVerificationUrl = sentinelUri,
    this.installationParameters,
    this.flags,
    this.icon = sentinelImageBuilder,
    this.coverImage = sentinelImageBuilder,
    this.interactionsEndpointUrl = sentinelUri,
    this.tags,
    this.integrationTypesConfig,
  });

  @override
  Map<String, Object?> build() => {
        if (customInstallUrl != null) 'custom_install_url': customInstallUrl!.toString(),
        if (description != null) 'description': description,
        if (!identical(roleConnectionsVerificationUrl, sentinelUri)) 'role_connections_verification_url': roleConnectionsVerificationUrl?.toString(),
        if (installationParameters != null)
          'install_params': {
            'scopes': installationParameters!.scopes,
            'permissions': installationParameters!.permissions.value.toString(),
          },
        if (integrationTypesConfig != null)
          'integration_types_config': integrationTypesConfig!.map((key, value) => MapEntry(key.value.toString(), {
                if (value.oauth2InstallParameters != null)
                  'oauth2_install_params': {
                    'scopes': value.oauth2InstallParameters!.scopes,
                    'permissions': value.oauth2InstallParameters!.permissions.value.toString(),
                  },
              })),
        if (flags != null) 'flags': flags!.value,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (!identical(coverImage, sentinelImageBuilder)) 'cover_image': coverImage?.buildDataString(),
        if (!identical(interactionsEndpointUrl, sentinelUri)) 'interactions_endpoint_url': interactionsEndpointUrl?.toString(),
        if (tags != null) 'tags': tags,
      };
}
