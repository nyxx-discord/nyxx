import '../../discord.dart';

/// Sent when a member's presence updates.
class PresenceUpdateEvent {
  /// The old member, may be null.
  Member oldMember;

  /// The new member.
  Member newMember;

  /// Constructs a new [PresenceUpdateEvent].
  PresenceUpdateEvent(Client client, Map<String, dynamic> json) {
    Map<String, dynamic> data = json['d'] as Map<String, dynamic>;
    if (data['user'].length > 1) {
      data['user'] = data['user'] as Map<String, dynamic>;
    } else {
      data['user'] = client.users[data['user']['id']].raw as Map<String, dynamic>;
    }

    this.newMember = new Member(client, data);
    this.oldMember = newMember.guild.members[newMember.id];

    this.newMember.guild.members.add(this.newMember);
    client.users.add(this.newMember.toUser());
    client.internal.events.onPresenceUpdate.add(this);
  }
}