part of nyxx_interactions;

class ArgChoice {

  /// This options name.
  late final String name;

  /// This options int value. If there is an int value there can't be a [SlashArgChoice.stringValue]
  late final int? intValue;

  /// This options string value. If there is an string value there can't be a [SlashArgChoice.intValue]
  late final String? stringValue;

  /// A Choice for the user to input in int & string args. You can only have an int or string option.
  ArgChoice(this.name, dynamic value) {
    if(value is String) {
      this.stringValue = value;
    }
    if(value is int) {
      this.intValue = value;
    }
    if(value is! int && value is! String) {
      throw 'InvalidParamTypeError: Please send a string if its a string arg or an int if its an int arg.';
    }
  }

  Map<String, dynamic> _build() => {
    "name": this.name,
    "value": this.stringValue ?? this.intValue
  };
}
