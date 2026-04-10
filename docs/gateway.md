Discord's Gateway API allows bots and applications to receive events from
Discord over a websocket connection. This topic contains the classes used by
`nyxx` to manage the lifecycle of this connection.

This topic does not contain models for the events received from the Gateway. For
that, see the [Events] topic.

A client's overall connection to the Gateway is managed by the [Gateway] class.
It is responsible for receiving [GatewayEvents] from [Shard]s, before parsing
them and forwarding them to [Gateway.events] (which is also accessible via the
`NyxxGateway.onXXXEvent` streams). It is also responsible for creating and
coordinating several [Shard] instances.

Each [Shard] maintains a single websocket connection to Discord's Gateway API.
A client can run one or more shards for better resiliency and load balancing,
and shards can even be split across several different clients running separately
for very large bots. This can be configured using
[GatewayApiOptions.totalShards] and [GatewayApiOptions.shards].

The websocket connection for each [Shard], as well as the connection lifecycle
and reconnection logic, are run in a separate [Isolate]. Communication with the
worker isolate is performed using [ShardMessage]s and [GatewayMessage]s. These
messages can be used to listen for connection lifecycle events such as
reconnects and heartbeats.

Decompression, JSON/ETF deserialization and some parsing happens in the worker
isolate. Events are then sent to the main isolate where the [Gateway] will
finish the rest of the parsing (notably parsing [RawDispatchEvent]s into
[DispatchEvent]s that reference the client).

[GatewayManager], like other [Managers], provides Dart APIs for the HTTP
endpoints relating to the gateway. In particular, it can be used to obtain a
[GatewayBot] instance with the needed configuration to connect to the Gateway
API. Hence, it is available on [NyxxRest] instances. [NyxxGateway] instances
only have a [Gateway] instance that extends [GatewayManager].

[Events]: ./events-topic.html
[Gateway]: ../nyxx/Gateway-class.html
[GatewayEvents]: ../nyxx/GatewayEvent-class.html
[Shard]: ../nyxx/Shard-class.html
[Gateway.events]: ../nyxx/Gateway/events.html
[GatewayApiOptions.totalShards]: ../nyxx/GatewayApiOptions/totalShards.html
[GatewayApiOptions.shards]: ../nyxx/GatewayApiOptions/shards.html
[Isolate]: https://api.dart.dev/dart-isolate/Isolate-class.html
[ShardMessage]: ../nyxx/ShardMessage-class.html
[GatewayMessage]: ../nyxx/GatewayMessage-class.html
[RawDispatchEvent]: ../nyxx/RawDispatchEvent-class.html
[DispatchEvent]: ../nyxx/DispatchEvent-class.html
[GatewayManager]: ../nyxx/GatewayManager-class.html
[Managers]: ./managers-topic.html
[GatewayBot]: ../nyxx/GatewayBot-class.html
[NyxxRest]: ../nyxx/NyxxRest-class.html
[NyxxGateway]: ../nyxx/NyxxGateway-class.html
