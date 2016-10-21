library discord.discord_browser;

import 'package:w_transport/w_transport_browser.dart'
    show configureWTransportForBrowser;

/// Configures the client to run in a browser.
void configureDiscordForBrowser() {
  configureWTransportForBrowser();
}
