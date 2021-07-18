part of nyxx_interactions;

/// A specified choice for a slash command argument.
class ArgChoiceBuilder extends Builder {
  /// This options name.
  String name;

  /// This is the options value, must be int or string
  dynamic value;

  /// A Choice for the user to input in int & string args.
  /// You can only have an int or string option.
  ArgChoiceBuilder(this.name, this.value) {
    if (value is! int && value is! String) {
      throw ArgumentError("Value could be either String or int type");
    }
  }

  RawApiMap build() => { "name": this.name, "value": this.value };
}
