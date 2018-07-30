part of nyxx.commands;

abstract class TypeConverter<T> {
  T parse(String from, Message msg);
  Type getType();
}
