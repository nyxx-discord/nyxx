part of nyxx_interactions;

/// Interaction extension for Nyxx. Allows use of: Slash Commands.
class Interactions {
  ///
  Interactions(Nyxx client, [bool force = false]) {
    client.shardManager.rawEvent.listen((event) {});
  }
}
