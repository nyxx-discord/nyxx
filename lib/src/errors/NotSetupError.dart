part of nyxx;

/// Thrown when you don't setup the client first.
/// See [configureDiscordForBrowser()](https://www.dartdocs.org/documentation/nyxx/latest/discord.browser/configureDiscordForBrowser.html)
/// or [configureDiscordForVM()](https://www.dartdocs.org/documentation/nyxx/latest/discord.vm/configureDiscordForVM.html)
class NotSetupError implements Exception {
  /// Returns a string representation of this object.
  @override
  String toString() => "NotSetupError";
}
