part of discord;

/// Sent when a member's presence updates.
class PresenceUpdateEvent {
  /// The old member, may be null.
  Member oldMember;

  /// The new member.
  Member newMember;

  PresenceUpdateEvent._new(Client client, Map<String, dynamic> json) {
    Map<String, dynamic> data = json['d'] as Map<String, dynamic>;
    if (data['user'].length > 1) {
      data['user'] = data['user'] as Map<String, dynamic>;
    } else {
      data['user'] =
          client.users[data['user']['id']].raw as Map<String, dynamic>;
    }

    this.newMember = new Member._new(client, data);
    this.oldMember = newMember.guild.members[newMember.id];

    this.newMember.guild.members.add(this.newMember);
    client.users.add(this.newMember.toUser());
    client._events.onPresenceUpdate.add(this);
  }
}
