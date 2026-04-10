This topic contains classes used to construct models that can be serialized and
sent to the Discord API, for example as a request to create or update an entity.

[Builder]s can usually be split into two categories: [CreateBuilder]s are used
for creating new instances and may have required fields. [UpdateBuilder]s are
used to update existing instances and generally have all optional fields.

Most builders are named after the [Model] they correspond to. A [CreateBuilder]
for a given model will usually be named the same as the model, with the
`-Builder` suffix. If the model also has an [UpdateBuilder], it will be named
the same as the model, with the `-UpdateBuilder` suffix.

The type argument on a builder is used to indicate the [Model] that builder is
for. Some builders do not have a corresponding model (they are "upload-only")
and will use themselves as their type argument.

Some builders are shared for multiple variations of a given model. For example,
an [ApplicationCommandBuilder] can be used to create a builder for a chat
command, a user command, or a message command depending on the value of the
[ApplicationCommandBuilder.type] field. Such builders may have restrictions on
which fields are compatible with which type, in which case named constructors
corresponding to each possible type are provided with only the allowed fields.

[Builder]: ../nyxx/Builder-class.html
[CreateBuilder]: ../nyxx/CreateBuilder-class.html
[UpdateBuilder]: ../nyxx/UpdateBuilder-class.html
[Model]: ./models-topic.html
[ApplicationCommandBuilder]: ../nyxx/ApplicationCommandBuilder-class.html
[ApplicationCommandBuilder.type]: ../nyxx/ApplicationCommandBuilder/type.html
