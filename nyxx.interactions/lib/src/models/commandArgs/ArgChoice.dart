part of nyxx_interactions;

/// A specified choice for a slash command argument.
class ArgChoice {
  /// This options name.
  late final String name;

  /// This is the options value, must be int or string
  late final dynamic value;

  /// A Choice for the user to input in int & string args. You can only have an int or string option.
  ArgChoice(this.name, dynamic value) {
    if (value is! int && value is! String) {
      throw "InvalidParamTypeError: Please send a string if its a string arg or an int if its an int arg.";
    }

    this.value = value;
  }

  Map<String, dynamic> _build() => {"name": this.name, "value": this.value};
}
