Plugins provide a structured way for code to access a `nyxx` client, as well as
allowing HTTP requests and Gateway events to be intercepted.

To create your own plugin, create a subclass of [NyxxPlugin] and specify the
type of client the plugin can be used with in the type parameter. Plugins that
have per-client state should override [NyxxPlugin.createState] and return a
subclass of [NyxxPluginState]. The methods in [NyxxPlugin] and [NyxxPluginState]
can then be overridden to execute code at various points of the client
lifecycle.

Plugins can be added to clients using [ClientOptions.plugins].

Nyxx also comes with [some prebuilt plugins](#properties).

[NyxxPlugin]: ../nyxx/NyxxPlugin-class.html
[NyxxPlugin.createState]: ../nyxx/NyxxPlugin/createState.html
[NyxxPluginState]: ../nyxx/NyxxPluginState-class.html
[ClientOptions.plugins]: ../nyxx/ClientOptions/plugins.html
