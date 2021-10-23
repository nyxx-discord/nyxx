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

  /// TODO: ??
  bool get teamUser;

  /// If user is system user
  bool get system;

  /// True if user has level two of Bug Hunter badge
  bool get bugHunterLevel2;

  /// True if user is verified bot
  bool get verifiedBot;

  /// True if user is Early Verified Bot Developer
  bool get earlyVerifiedBotDeveloper;

  /// rue if user is Discord Certified Moderator
  bool get certifiedModerator;
}

// TODO: just store int and in getter check if its applied
/// Additional flags associated with user account. Describes if user has certain
/// features like joined into one of houses or is discord employee.
class UserFlags implements IUserFlags {
  /// True if user is discord employee
  @override
  late final bool discordEmployee;

  /// True if user is discord partner
  @override
  late final bool discordPartner;

  /// True if user has HypeSquad Events badge
  @override
  late final bool hypeSquadEvents;

  /// True if user has level one of Bug Hunter badge
  @override
  late final bool bugHunterLevel1;

  /// True if user has HypeSquad Bravery badge
  @override
  late final bool houseBravery;

  /// True if user has HypeSquad Brilliance badge
  @override
  late final bool houseBrilliance;

  /// True if user has HypeSquad Balance badge
  @override
  late final bool houseBalance;

  /// True if user has Early Supporter badge
  @override
  late final bool earlySupporter;

  /// TODO: ??
  @override
  late final bool teamUser;

  /// If user is system user
  @override
  late final bool system;

  /// True if user has level two of Bug Hunter badge
  @override
  late final bool bugHunterLevel2;

  /// True if user is verified bot
  @override
  late final bool verifiedBot;

  /// True if user is Early Verified Bot Developer
  @override
  late final bool earlyVerifiedBotDeveloper;

  /// rue if user is Discord Certified Moderator
  @override
  late final bool certifiedModerator;

  /// Creates an instance of [UserFlags]
  UserFlags(int raw) {
    this.discordEmployee = PermissionsUtils.isApplied(raw, 1 << 0);
    this.discordPartner = PermissionsUtils.isApplied(raw, 1 << 1);
    this.hypeSquadEvents = PermissionsUtils.isApplied(raw, 1 << 2);
    this.bugHunterLevel1 = PermissionsUtils.isApplied(raw, 1 << 3);
    this.houseBravery = PermissionsUtils.isApplied(raw, 1 << 6);
    this.houseBrilliance = PermissionsUtils.isApplied(raw, 1 << 7);
    this.houseBalance = PermissionsUtils.isApplied(raw, 1 << 8);
    this.earlySupporter = PermissionsUtils.isApplied(raw, 1 << 9);
    this.teamUser = PermissionsUtils.isApplied(raw, 1 << 10);
    this.system = PermissionsUtils.isApplied(raw, 1 << 12);
    this.bugHunterLevel2 = PermissionsUtils.isApplied(raw, 1 << 14);
    this.verifiedBot = PermissionsUtils.isApplied(raw, 1 << 16);
    this.earlyVerifiedBotDeveloper = PermissionsUtils.isApplied(raw, 1 << 17);
    this.certifiedModerator = PermissionsUtils.isApplied(raw, 1 << 18);
  }
}
