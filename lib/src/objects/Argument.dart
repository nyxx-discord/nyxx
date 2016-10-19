part of discord;

/// An argument for a command.
class Argument {
  int _type;

  /// The argument name.
  String name;

  /// The value type. Only used for options and positional. NOT IN USE RIGHT NOW.
  ///
  /// Possible values: int, str, user, channel, guild, bool, dynamic.
  String valueType;

  /// Allowed values. Only used for options and positional.
  List<String> allowed;

  /// Whether or not this is required. Always true for positional arguments.
  bool required;

  /// Whether or not to allow `--no-FLAG`. Only used for flags;
  bool negatable;

  /// The default value if not provided.
  dynamic defaultValue;

  /// An abbreviation.
  String abbr;

  /// Whether or not to allow multiple options. If true, will return a list of options.
  bool allowMultiple;

  /// Whether or not to split options by commas into an array.
  bool splitCommas;

  /// Creates a new positional argument.
  Argument.positional(this.name,
      {this.valueType: "dynamic",
      this.allowed,
      this.required: true,
      this.defaultValue}) {
    this._type = 0;
  }

  /// Creates a new flag.
  Argument.flag(this.name,
      {this.required: false,
      this.negatable: true,
      this.defaultValue: null,
      this.abbr}) {
    if (!this.defaultValue is bool && this.defaultValue != null)
      throw new TypeError();
    this._type = 1;
  }

  /// Creates a new option.
  Argument.option(this.name,
      {this.required: false,
      this.defaultValue: null,
      this.abbr,
      this.allowed,
      this.allowMultiple,
      this.splitCommas}) {
    this._type = 2;
  }
}
