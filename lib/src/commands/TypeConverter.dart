part of nyxx.commands;

/// Interface for creating TypeConverter.
/// Overriding this class allows to later register it into [CommandsFramework]
abstract class TypeConverter<T> {
  T parse(String from, Message msg);
  Type get _type => T;
}
