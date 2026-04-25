This topic contains classes representing API structures that are the basis of a
set of API endpoints or other structures. These will often be subclasses of
[SnowflakeEntity], for entities that are referenced by a [Snowflake] ID.

Most entities will have a corresponding [Manager] that contains parsing for
related [Models] and Dart APIs for related endpoints. For more information, see
the [Managers] topic.

Entities are also [Models] in that they contain structured data returned by
the API. Unlike most models though, entities will often provide methods that act
on said entity. These methods are often simply shortcuts to a corresponding
[Manager] method, but calling them on an entity directly often leads to cleaner
code.

Entities, like all [Models], are immutable structures. Using a method on an
entity that updates it (for example [WritableSnowflakeEntity.update]) will not
modify the instance itself; instead, a new instance will be returned by the
updating method and should be used instead.

Most entities will have a corresponding "partial" entity. A partial entity is a
reference to an entity, and can therefore be used to access that entity's
methods (which often only require knowing its ID) without having to fetch the
entity's model from the API. Partial entities can be accessed using
[Manager.operator[]](../nyxx/ReadOnlyManager/operator_get.html) and providing
the entity's ID.

For example, you can write the following code to list a [Guild]'s channels
without having to fetch the [Guild] itself:

```dart
client.guilds[GUILD_ID].fetchChannels();
```

You can obtain the full model for a partial entity by using the [get] method.

[SnowflakeEntity]: ../nyxx/SnowflakeEntity-class.html
[Snowflake]: ../nyxx/Snowflake-class.html
[Manager]: ../nyxx/Manager-class.html
[Models]: ./models-topic.html
[Managers]: ./managers-topic.html
[WritableSnowflakeEntity.update]: ../nyxx/WritableSnowflakeEntity/update.html
[Guild]: ../nyxx/Guild-class.html
[get]: ../nyxx/SnowflakeEntity/get.html
