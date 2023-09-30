import 'package:nyxx/src/http/cdn/cdn_asset.dart';
import 'package:nyxx/src/http/managers/application_manager.dart';
import 'package:nyxx/src/http/managers/entitlement_manager.dart';
import 'package:nyxx/src/http/route.dart';
import 'package:nyxx/src/models/guild/guild.dart';
import 'package:nyxx/src/models/locale.dart';
import 'package:nyxx/src/models/permissions.dart';
import 'package:nyxx/src/models/sku.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/team.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';
import 'package:nyxx/src/utils/to_string_helper/to_string_helper.dart';

/// A partial [Application] object.
// We intentionally do not use SnowflakeEntity as applications do not have the same access in the API as other entities with IDs, so they cannot be thought of
// as being in a "group".
class PartialApplication with ToStringHelper {
  /// The ID of this application.
  final Snowflake id;

  /// The manager for this application.
  final ApplicationManager manager;

  /// An [EntitlementManager] for this application's [Entitlement]s.
  EntitlementManager get entitlements => EntitlementManager(manager.client.options.entitlementConfig, manager.client, applicationId: id);

  /// Create a new [PartialApplication].
  PartialApplication({required this.id, required this.manager});

  /// Fetch this application's role connection metadata.
  Future<List<ApplicationRoleConnectionMetadata>> fetchRoleConnectionMetadata() => manager.fetchApplicationRoleConnectionMetadata(id);

  /// Update and fetch this application's role connection metadata.
  Future<List<ApplicationRoleConnectionMetadata>> updateRoleConnectionMetadata() => manager.updateApplicationRoleConnectionMetadata(id);

  /// List this application's SKUs.
  Future<List<Sku>> listSkus() => manager.listSkus(id);
}

/// {@template application}
/// An OAuth2 application.
/// {@endtemplate}
class Application extends PartialApplication {
  /// The name of this application.
  final String name;

  /// The hash of this application's icon.
  final String? iconHash;

  /// This application's description.
  final String description;

  /// A list of rpc origin urls, if rpc is enabled.
  final List<String>? rpcOrigins;

  /// Whether the bot account associated with this application can be added to guilds by anyone.
  final bool isBotPublic;

  /// Whether the bot account associated with this application requires the OAuth2 code grant to be completed before joining a guild.
  final bool botRequiresCodeGrant;

  /// The bot user associated with the application.
  final PartialUser? bot;

  /// The URL of this application's Terms of Service.
  final Uri? termsOfServiceUrl;

  /// The URL of this application's Privacy Policy.
  final Uri? privacyPolicyUrl;

  /// The owner of this application.
  final PartialUser? owner;

  /// A hex string used to verify interactions.
  final String verifyKey;

  /// If this application belongs to a team, the team which owns this app.
  final Team? team;

  /// The ID of the guild associated with this application.
  final Snowflake? guildId;

  /// The guild associated with this application.
  final PartialGuild? guild;

  /// If this application is a game sold on Discord, the ID of the "Game SKU" that is created, if it exists.
  final Snowflake? primarySkuId;

  /// If this application is a game sold on Discord, the URL slug that links to the store page.
  final String? slug;

  /// The hash of this application's rich presence invite cover image.
  final String? coverImageHash;

  /// The public flags for this application.
  final ApplicationFlags flags;

  /// The approximate number of guilds this bot has been added to.
  final int? approximateGuildCount;

  /// The list of redirect URIs for this application.
  final List<Uri>? redirectUris;

  /// The interactions endpoint URL for this application.
  final Uri? interactionsEndpointUrl;

  /// Up to 5 tags describing this application.
  final List<String>? tags;

  /// Settings for this application's default authorization link.
  final InstallationParameters? installationParameters;

  /// The custom authorization link for this application.
  final Uri? customInstallUrl;

  /// This application's role connection verification entry point.
  ///
  /// When configured, this will render the app as a verification method in the guild role verification configuration.
  final Uri? roleConnectionsVerificationUrl;

  /// {@macro application}
  Application({
    required super.id,
    required super.manager,
    required this.name,
    required this.iconHash,
    required this.description,
    required this.rpcOrigins,
    required this.isBotPublic,
    required this.botRequiresCodeGrant,
    required this.bot,
    required this.termsOfServiceUrl,
    required this.privacyPolicyUrl,
    required this.owner,
    required this.verifyKey,
    required this.team,
    required this.guildId,
    required this.guild,
    required this.primarySkuId,
    required this.slug,
    required this.coverImageHash,
    required this.flags,
    required this.approximateGuildCount,
    required this.redirectUris,
    required this.interactionsEndpointUrl,
    required this.tags,
    required this.installationParameters,
    required this.customInstallUrl,
    required this.roleConnectionsVerificationUrl,
  });

  /// This application's icon.
  CdnAsset? get icon => iconHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..appIcons(id: id.toString()),
          hash: iconHash!,
        );

  /// This application's cover image.
  CdnAsset? get coverImage => coverImageHash == null
      ? null
      : CdnAsset(
          client: manager.client,
          base: HttpRoute()..appIcons(id: id.toString()),
          hash: coverImageHash!,
        );
}

/// Flags for an [Application].
class ApplicationFlags extends Flags<ApplicationFlags> {
  /// Indicates if an app uses the Auto Moderation API.
  static const applicationAutoModerationRuleCreateBadge = Flag<ApplicationFlags>.fromOffset(6);

  /// Intent required for bots in 100 or more servers to receive presence_update events.
  static const gatewayPresence = Flag<ApplicationFlags>.fromOffset(12);

  /// Intent required for bots in under 100 servers to receive presence_update events, found on the Bot page in your app's settings.
  static const gatewayPresenceLimited = Flag<ApplicationFlags>.fromOffset(13);

  /// Intent required for bots in 100 or more servers to receive member-related events like guild_member_add. See the list of member-related events under GUILD_MEMBERS.
  static const gatewayGuildMembers = Flag<ApplicationFlags>.fromOffset(14);

  /// Intent required for bots in under 100 servers to receive member-related events like guild_member_add, found on the Bot page in your app's settings. See the list of member-related events under GUILD_MEMBERS.
  static const gatewayGuildMembersLimited = Flag<ApplicationFlags>.fromOffset(15);

  /// Indicates unusual growth of an app that prevents verification.
  static const verificationPendingGuildLimit = Flag<ApplicationFlags>.fromOffset(16);

  /// Indicates if an app is embedded within the Discord client (currently unavailable publicly).
  static const embedded = Flag<ApplicationFlags>.fromOffset(17);

  /// Intent required for bots in 100 or more servers to receive message content.
  static const gatewayMessageContent = Flag<ApplicationFlags>.fromOffset(18);

  /// Intent required for bots in under 100 servers to receive message content, found on the Bot page in your app's settings.
  static const gatewayMessageContentLimited = Flag<ApplicationFlags>.fromOffset(19);

  /// Indicates if an app has registered global application commands.
  static const applicationCommandBadge = Flag<ApplicationFlags>.fromOffset(23);

  /// Whether this application has the [applicationAutoModerationRuleCreateBadge] flag set.
  bool get usesApplicationAutoModerationRuleCreateBadge => has(applicationAutoModerationRuleCreateBadge);

  /// Whether this application has the [gatewayPresence] flag set.
  bool get hasGatewayPresence => has(gatewayPresence);

  /// Whether this application has the [gatewayPresenceLimited] flag set.
  bool get hasGatewayPresenceLimited => has(gatewayPresenceLimited);

  /// Whether this application has the [gatewayGuildMembers] flag set.
  bool get hasGatewayGuildMembers => has(gatewayGuildMembers);

  /// Whether this application has the [gatewayGuildMembersLimited] flag set.
  bool get hasGatewayGuildMembersLimited => has(gatewayGuildMembersLimited);

  /// Whether this application has the [verificationPendingGuildLimit] flag set.
  bool get isVerificationPendingGuildLimit => has(verificationPendingGuildLimit);

  /// Whether this application has the [embedded] flag set.
  bool get isEmbedded => has(embedded);

  /// Whether this application has the [gatewayMessageContent] flag set.
  bool get hasGatewayMessageContent => has(gatewayMessageContent);

  /// Whether this application has the [gatewayMessageContentLimited] flag set.
  bool get hasGatewayMessageContentLimited => has(gatewayMessageContentLimited);

  /// Whether this application has the [applicationCommandBadge] flag set.
  bool get hasApplicationCommandBadge => has(applicationCommandBadge);

  /// Create a new [ApplicationFlags].
  ApplicationFlags(super.value);
}

/// {@template installation_parameters}
/// Configuration for an [Application]'s authorization link.
/// {@endtemplate}
class InstallationParameters with ToStringHelper {
  /// The OAuth2 scopes to add the application to the guild with.
  final List<String> scopes;

  /// The [Permissions] to add the application to he guild with.
  final Permissions permissions;

  /// {@macro installation_parameters}
  InstallationParameters({
    required this.scopes,
    required this.permissions,
  });
}

/// {@template application_role_connection_metadata}
/// Metadata for an app's role connections.
/// {@endtemplate}
class ApplicationRoleConnectionMetadata with ToStringHelper {
  /// The type of connection.
  final ConnectionMetadataType type;

  /// The key of the entry in the metadata to check.
  final String key;

  /// The name of this role connection.
  final String name;

  /// A localized map of names for this role connection.
  final Map<Locale, String>? localizedNames;

  /// A description of this role connection.
  final String description;

  /// A localized map of descriptions for this role connection.
  final Map<Locale, String>? localizedDescriptions;

  /// {@macro application_role_connection_metadata}
  ApplicationRoleConnectionMetadata({
    required this.type,
    required this.key,
    required this.name,
    required this.localizedNames,
    required this.description,
    required this.localizedDescriptions,
  });
}

/// The type of an [ApplicationRoleConnectionMetadata].
enum ConnectionMetadataType {
  integerLessThanOrEqual._(1),
  integerGreaterThanOrEqual._(2),
  integerEqual._(3),
  integerNotEqual._(4),
  dateTimeLessThanOrEqual._(5),
  dateTimeGreaterThanOrEqual._(6),
  booleanEqual._(7),
  booleanNotEqual._(8);

  /// The value of this [ConnectionMetadataType].
  final int value;

  const ConnectionMetadataType._(this.value);

  /// Parse a [ConnectionMetadataType] from an [int].
  ///
  /// The [value] must be a valid connection metadata type.
  factory ConnectionMetadataType.parse(int value) => ConnectionMetadataType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown connection metadata type', value),
      );

  @override
  String toString() => 'ConnectionMetadataType($value)';
}
