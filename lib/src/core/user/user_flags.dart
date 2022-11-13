import 'package:nyxx/src/utils/permissions.dart';

abstract class IUserFlags {
  /// True if user is discord employee
  bool get discordEmployee;

  /// True if user is discord partner
  bool get discordPartner;

  /// True if user has HypeSquad Events badge
  bool get hypeSquadEvents;

  /// True if user has level one of Bug Hunter badge
  bool get bugHunterLevel1;

  /// True if user has HypeSquad Bravery badge
  bool get houseBravery;

  /// True if user has HypeSquad Brilliance badge
  bool get houseBrilliance;

  /// True if user has HypeSquad Balance badge
  bool get houseBalance;

  /// True if user has Early Supporter badge
  bool get earlySupporter;

  /// Team User
  bool get teamUser;

  /// If user is system user
  bool get system;

  /// True if user has level two of Bug Hunter badge
  bool get bugHunterLevel2;

  /// True if user is verified bot
  bool get verifiedBot;

  /// True if user is Early Verified Bot Developer
  bool get earlyVerifiedBotDeveloper;

  /// True if user is Discord Certified Moderator
  bool get certifiedModerator;

  /// True if user is an [Active Developer](https://support-dev.discord.com/hc/articles/10113997751447).
  bool get activeDeveloper;

  /// Raw flags value
  int get raw;
}

/// Additional flags associated with user account. Describes if user has certain
/// features like joined into one of houses or is discord employee.
class UserFlags implements IUserFlags {
  /// True if user is discord employee
  @override
  bool get discordEmployee => PermissionsUtils.isApplied(raw, 1 << 0);

  /// True if user is discord partner
  @override
  bool get discordPartner => PermissionsUtils.isApplied(raw, 1 << 1);

  /// True if user has HypeSquad Events badge
  @override
  bool get hypeSquadEvents => PermissionsUtils.isApplied(raw, 1 << 2);

  /// True if user has level one of Bug Hunter badge
  @override
  bool get bugHunterLevel1 => PermissionsUtils.isApplied(raw, 1 << 3);

  /// True if user has HypeSquad Bravery badge
  @override
  bool get houseBravery => PermissionsUtils.isApplied(raw, 1 << 6);

  /// True if user has HypeSquad Brilliance badge
  @override
  bool get houseBrilliance => PermissionsUtils.isApplied(raw, 1 << 7);

  /// True if user has HypeSquad Balance badge
  @override
  bool get houseBalance => PermissionsUtils.isApplied(raw, 1 << 8);

  /// True if user has Early Supporter badge
  @override
  bool get earlySupporter => PermissionsUtils.isApplied(raw, 1 << 9);

  @override
  bool get teamUser => PermissionsUtils.isApplied(raw, 1 << 10);

  /// If user is system user
  @override
  bool get system => PermissionsUtils.isApplied(raw, 1 << 12);

  /// True if user has level two of Bug Hunter badge
  @override
  bool get bugHunterLevel2 => PermissionsUtils.isApplied(raw, 1 << 14);

  /// True if user is verified bot
  @override
  bool get verifiedBot => PermissionsUtils.isApplied(raw, 1 << 16);

  /// True if user is Early Verified Bot Developer
  @override
  bool get earlyVerifiedBotDeveloper => PermissionsUtils.isApplied(raw, 1 << 17);

  /// rue if user is Discord Certified Moderator
  @override
  bool get certifiedModerator => PermissionsUtils.isApplied(raw, 1 << 18);

  @override
  bool get activeDeveloper => PermissionsUtils.isApplied(raw, 1 << 22);

  /// Raw flags value
  @override
  final int raw;

  /// Creates an instance of [UserFlags]
  UserFlags(this.raw);
}
