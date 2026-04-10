This topic contains all the classes that represent events received from
Discord's Gateway API.

It does not contain the logic for connecting to the Gateway itself. For that,
see the [Gateway] topic.

There are two main types of events received from the Gateway:
- Most subclasses of [GatewayEvent] are relevant for controlling session state.
  These events are handled by `nyxx` internally, but you can listen to them
  using [Gateway.messages] and looking for [EventReceived] events.
- Subclasses of [DispatchEvent] are sent when Discord informs your client of
  some state changing, such as a [Message] being created or a [User] updating
  their [Activity]. To listen for [DispatchEvent]s, use the [Gateway.events]
  stream, or one of the event-specific streams available on [NyxxGateway]
  (`client.onXXXEvent`). Note that only [RawDispatchEvent]s that have not been
  parsed will be emitted on the [Gateway.messages] stream.

To control which [DispatchEvent]s your client receives, please see
[GatewayApiOptions.intents].

[Gateway]: ./gateway-topic.html
[GatewayEvent]: ../nyxx/GatewayEvent-class.html
[Gateway.messages]: ../nyxx/Gateway/messages.html
[EventReceived]: ../nyxx/EventReceived-class.html
[DispatchEvent]: ../nyxx/DispatchEvent-class.html
[Message]: ../nyxx/Message-class.html
[User]: ../nyxx/User-class.html
[Activity]: ../nyxx/Activity-class.html
[Gateway.events]: ../nyxx/Gateway/events.html
[NyxxGateway]: ../nyxx/NyxxGateway-class.html
[RawDispatchEvent]: ../nyxx/RawDispatchEvent-class.html
[GatewayApiOptions.intents]: ../nyxx/GatewayApiOptions/intents.html
