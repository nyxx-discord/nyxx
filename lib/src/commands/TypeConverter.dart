part of nyxx.commands;

/// Interface for creating TypeConverter.
/// Overriding this class alows to later register it into [CommandsFramework]
abstract class TypeConverter<T> {
  T parse(String from, Message msg);
  Type getType() => T;
}
