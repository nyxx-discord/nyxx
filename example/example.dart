import 'dart:io';

import 'package:nyxx/nyxx.dart';

void main() async {
  // RAII Improvements - client acquisition and connection (initialization) are now one operation.
  // This will be especially handy when dealing with plugins & no need for a ready event before.
  // Also no longer a need to have many late fields.
  final client = await Nyxx.connectRest(Platform.environment['TOKEN']!);

  // Less monolithic - HttpEndpoints and the parsing of objects have been moved to 'manager' classes
  // for each type of resource. These are accessible through getters on the client (only users are
  // implemented for now).
  final myUser = await client.users.fetchCurrentUser();

  // Development improvements - toString() is implemented for all classes and leverages dart:mirrors
  // when possible to print entire objects.
  print(myUser);

  // Support for partial objects (at minimum with only an ID). These can be accessed for an
  // arbitrary id on a manager with the `[]` operator and allow API operations without fetching the
  // entire object from the API.
  const abitofevrythingId = Snowflake(506759329068613643);
  final partialAbitofevrything = client.users[abitofevrythingId];

  // There are no API operations for arbitrary users other then fetch so... this is our demo. But
  // theoretically any API operation could be called on this object.
  // These partial objects can also sometimes be returned from the API.
  print(await partialAbitofevrything.fetch());

  // Of course you could also directly call the methods on the manager:
  print(await client.users.fetch(abitofevrythingId));

  // The API is also more type safe (no more dynamic!, see for example the Snowflake API). The
  // ApiOptions class will make it easy to implement different authentication methods (for example
  // OAuth2).

  // And of course all the other benefits of a project rewrite: better project structure &
  // documentation improvements could be possible.

  // This all takes time though so... what do you think?
}
