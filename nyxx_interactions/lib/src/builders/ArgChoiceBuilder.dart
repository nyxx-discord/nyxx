part of nyxx_interactions;

/// A specified choice for a slash command argument.
class ArgChoiceBuilder implements Builder {
  /// This options name.
  String name;

  /// This is the options value, must be int or string
  dynamic value;

  /// A Choice for the user to input in int & string args.
  /// You can only have an int or string option.
  ArgChoiceBuilder(this.name, this.value) {
    if (value is! int && value is! String) {
      throw ArgumentError("Please send a string if its a string arg or an int if its an int arg");
    }
  }

  Map<String, dynamic> _build() => { "name": this.name, "value": this.value };
}
