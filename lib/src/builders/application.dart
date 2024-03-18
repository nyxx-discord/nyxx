import 'package:nyxx/src/builders/builder.dart';
import 'package:nyxx/src/builders/image.dart';
import 'package:nyxx/src/builders/sentinels.dart';
import 'package:nyxx/src/models/application.dart';
import 'package:nyxx/src/utils/flags.dart';

class ApplicationIntegrationTypeConfigurationBuilder extends CreateBuilder<ApplicationIntegrationTypeConfiguration> {
  /// Install params for each installation context's default in-app authorization link.
  final InstallationParameters? oauth2InstallParameters;

  ApplicationIntegrationTypeConfigurationBuilder({this.oauth2InstallParameters});

  @override
  Map<String, Object?> build() => {
        if (oauth2InstallParameters != null)
          'oauth2_install_params': {
            'scopes': oauth2InstallParameters!.scopes,
            'permissions': oauth2InstallParameters!.permissions.value.toString(),
          },
      };
}

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

  Map<ApplicationIntegrationType, ApplicationIntegrationTypeConfigurationBuilder>? integrationTypesConfig;

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
          'integration_types_config': {
            for (final MapEntry(:key, :value) in integrationTypesConfig!.entries) key.value.toString(): value.build(),
          },
        if (flags != null) 'flags': flags!.value,
        if (!identical(icon, sentinelImageBuilder)) 'icon': icon?.buildDataString(),
        if (!identical(coverImage, sentinelImageBuilder)) 'cover_image': coverImage?.buildDataString(),
        if (!identical(interactionsEndpointUrl, sentinelUri)) 'interactions_endpoint_url': interactionsEndpointUrl?.toString(),
        if (tags != null) 'tags': tags,
      };
}
