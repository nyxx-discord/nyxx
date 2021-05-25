part of nyxx;

/// Additional flags associated with user account. Describes if user has certain
/// features like joined into one of houses or is discord employee.
class UserFlags {
  /// True if user is discord employee
  late final bool discordEmployee;

  /// True if user is discord partner
  late final bool discordPartner;

  /// True if user has HypeSquad Events badge
  late final bool hypeSquadEvents;

  /// True if user has level one of Bug Hunter badge
  late final bool bugHunterLevel1;

  /// True if user has HypeSquad Bravery badge
  late final bool houseBravery;

  /// True if user has HypeSquad Brilliance badge
  late final bool houseBrilliance;

  /// True if user has HypeSquad Balance badge
  late final bool houseBalance;

  /// True if user has Early Supporter badge
  late final bool earlySupporter;

  /// TODO: ??
  late final bool teamUser;

  /// If user is system user
  late final bool system;

  /// True if user has level two of Bug Hunter badge
  late final bool bugHunterLevel2;

  /// True if user is verified bot
  late final bool verifiedBot;

  /// True if user is Early Verified Bot Developer
  late final bool earlyVerifiedBotDeveloper;

  /// rue if user is Discord Certified Moderator
  late final bool certifiedModerator;

  UserFlags._new(int raw) {
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
