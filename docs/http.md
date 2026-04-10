Discord's HTTP API provides endpoints for accessing and updating entities. This
topic contains the classes used by `nyxx` to create and send requests to the
API, as well as handling the responses sent back.

This topic does not contain the classes responsible for serialization or
exposing Dart APIs corresponding to specific HTTP endpoints. For that, see the
[Managers] topic.

The core of `nyxx`'s HTTP component is the [HttpHandler] class, wrapping a
`package:http` [Client]. It exposes two methods: [HttpHandler.execute] and
[HttpHandler.executeSafe] both of which will send a request and return the
associated response. [HttpHandler.executeSafe] performs additional checks on the
status code of the response and will throw an error if the response was not
successful.

[CdnAsset]s also expose methods for making HTTP requests to the Discord CDN.
Notably, they allow for streaming responses, which [HttpHandler] does not.

The Discord API returns rich error information when a request is not successful.
This information is available on [HttpResponseError], containing an
[HttpErrorData] instance with detailed information on the request fields causing
the error ([FieldError]).

The outline of sending a request is detailed below.

### 1. Request creation

A request is created by constructing an instance of [HttpRequest], or rather,
one of its subtypes (a [BasicRequest], [MultipartRequest] or [CdnRequest]).

The request object is then passed to [HttpHandler.execute] or
[HttpHandler.executeSafe].

### 2. Plugin interception

[Plugins] are then allowed to intercept the request by overriding
[NyxxPlugin.interceptRequest]. These interceptors are called immediately after
the request is submitted.

### 3. OAuth2 credential check

If using OAuth2 credentials, they are checked and refreshed if needed.

### 4. Rate limiting

A stopwatch for timing the request duration is started and will be used to
update [HttpHandler.latency] once the request is completed.

Then, predictive rate limiting is applied to the request. Rate limiting
information is stored in [HttpBucket]s, which track how many requests are
allowed in the current window and when the current window resets. The request is
associated with an [HttpBucket] by its [rateLimitId], which is determined by the
request endpoint.

An [HttpRoute] is used to represent this endpoint, built by
joining several [HttpRoutePart]s together. Each [HttpRoutePart] can be
parameterized (by an ID, for example) and can declare whether its parameter is a
top-level parameter, which affects bucket allocation. For more information, see
the [Discord documentation](https://docs.discord.com/developers/topics/rate-limits).

The [rateLimitId] is then combined information from prior responses to determine
which bucket the requests falls into. If the bucket cannot allow any more
requests in the current window, the request is held until the bucket resets.

Global rate limiting is also applied here. While global rate limits are not
predicted, if a request encounters a global rate limit then all future requests
will be withheld until the time indicated in the rate limited response.

If a request is rate limited at this stage, an event will be emitted on
[HttpHandler.onRateLimit] with `isAnticipated` set to `true`. A request may be
rate limited multiple times before it moves onto the next stage.

### 5. Request sending

The [HttpRequest] is converted to a `package:http` [Request] using
[HttpRequest.prepare] and is then sent using the underlying `package:http`
[Client].

A stopwatch is started to measure the real network latency. It will be used to
update [HttpHandler.realLatency] once the response arrives.

### 6. Response processing

Once received, the response headers are used to update the request's
[HttpBucket] for future requests.

The body is then received and the full response is converted to a
[HttpResponseSuccess] or a [HttpResponseError] based on a simple status code
check.

If the response code indicates a rate limit was hit (status code 429), the
global rate limit reset is updated (if applicable) and the request goes back to
step 3 to be retried. An event is emitted on [HttpHandler.onRateLimit] with
`isAnticipated` set to `false`.

### 7. Status checks

If [HttpHandler.execute] was used, the response is returned as-is.

If [HttpHandler.executeSafe] was used, the response is returned only if it as a
[HttpResponseSuccess]. If it is a [HttpResponseError], it is thrown as an
exception.

[Managers]: ./managers-topic.html
[HttpHandler]: ../nyxx/HttpHandler-class.html
[Client]: https://pub.dev/documentation/http/latest/http/Client-class.html
[HttpHandler.execute]: ../nyxx/HttpHandler/execute.html
[HttpHandler.executeSafe]: ../nyxx/HttpHandler/executeSafe.html
[CdnAsset]: ../nyxx/CdnAsset-class.html
[HttpResponseError]: ../nyxx/HttpResponseError-class.html
[HttpErrorData]: ../nyxx/HttpErrorData-class.html
[FieldError]: ../nyxx/FieldError-class.html
[HttpRequest]: ../nyxx/HttpRequest-class.html
[BasicRequest]: ../nyxx/BasicRequest-class.html
[MultipartRequest]: ../nyxx/MultipartRequest-class.html
[CdnRequest]: ../nyxx/CdnRequest-class.html
[Plugins]: ./plugins-topic.html
[NyxxPlugin.interceptRequest]: ../nyxx/NyxxPlugin/interceptRequest.html
[HttpHandler.latency]: ../nyxx/HttpHandler/latency.html
[HttpBucket]: ../nyxx/HttpBucket-class.html
[rateLimitId]: ../nyxx/HttpRequest/rateLimitId.html
[HttpRoute]: ../nyxx/HttpRoute-class.html
[HttpRoutePart]: ../nyxx/HttpRoutePart-class.html
[HttpHandler.onRateLimit]: ../nyxx/HttpHandler/onRateLimit.html
[Request]: https://pub.dev/documentation/http/latest/http/Request-class.html
[HttpRequest.prepare]: ../nyxx/HttpRequest/prepare.html
[HttpHandler.realLatency]: ../nyxx/HttpHandler/realLatency.html
[HttpResponseSuccess]: ../nyxx/HttpResponseSuccess-class.html
