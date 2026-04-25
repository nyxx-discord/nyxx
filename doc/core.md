The classes in this topic provide the structure upon which the rest of the
library is built.

The central component of the `nyxx` library is the client: it encapsulates and
manages the lifecycle of several components that are responsible for accessing
the Discord API. All clients implement the [Nyxx] interface, and static methods
on that same class can be used to create specific client instances ([NyxxRest],
[NyxxOAuth2], or [NyxxGateway]).

Clients can be configured using [ApiOptions] and [ClientOptions]. Some clients
will be configured by a subtype of these configuration classes. [ApiOptions] are
used to configure how the client interacts with the Discord API itself, whereas
[ClientOptions] are used to configure client-side only behavior, such as plugins
and caching.

All clients will expose a [HttpHandler] that is used for performing HTTP
requests to the Discord API. For more information, see the [HTTP] topic.

Most users will not interact with the client's [HttpHandler], but will rather
use the [Managers] exposed by the client that provide deserialization for
[Models] and [Entities], as well as concrete Dart APIs corresponding to API
endpoints. Each [Manager] is usually attached to one or more kinds of [Entity],
and methods on [Entities] are usually just shortcuts to a corresponding
[Manager] method. For more information, see the [Managers] topic.

[Managers] also provide access to the client's caching system. While caches are
stored centrally in a [CacheManager], [Managers] are responsible for creating
and updating individual [Cache]s, which can be accessed directly via
[Manager.cache], by using the [Manager.get] method, or by using
[SnowflakeEntity.get] (which is a shorthand for [Manager.get]).

[Manager]s sometimes require the user to specify the structure of an entity to
create or update. While [Models] and [Entities] are received from the Discord
API, [Builders] allow users to create structures that are sent to the Discord
API. For more information, see the [Builders] topic.

Clients that connect to Discord's Gateway API do so using a
[Gateway](https://pub.dev/documentation/nyxx/latest/nyxx/Gateway-class.html)
instance. For more information on how the connection lifecycle is managed, see
the [Gateway] topic. For more information on the events the client can receive,
see the [Events] topic.

Finally, clients can be customized by [Plugins]. These provide a good way to
encapsulate functionality and `nyxx` comes with some built-in plugins. For more
information, see the [Plugins] topic.

[Nyxx]: ../nyxx/Nyxx-class.html
[NyxxRest]: ../nyxx/NyxxRest-class.html
[NyxxOAuth2]: ../nyxx/NyxxOAuth2-class.html
[NyxxGateway]: ../nyxx/NyxxGateway-class.html
[ApiOptions]: ../nyxx/ApiOptions-class.html
[ClientOptions]: ../nyxx/ClientOptions-class.html
[HttpHandler]: ../nyxx/HttpHandler-class.html
[HTTP]: ./http-topic.html
[Managers]: ./managers-topic.html
[Models]: ./models-topic.html
[Entities]: ./entities-topic.html
[Manager]: ../nyxx/Manager-class.html
[Entity]: ./entities-topic.html
[CacheManager]: ../nyxx/CacheManager-class.html
[Cache]: ../nyxx/Cache-class.html
[Manager.cache]: ../nyxx/ReadOnlyManager/cache.html
[Manager.get]: ../nyxx/ReadOnlyManager/get.html
[SnowflakeEntity.get]: ../nyxx/SnowflakeEntity/get.html
[Builders]: ./builders-topic.html
[Gateway]: ./gateway-topic.html
[Events]: ./events-topic.html
[Plugins]: ./plugins-topic.html
