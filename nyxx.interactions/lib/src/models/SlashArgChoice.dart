part of nyxx_interactions;

class SlashArgChoice {

  /// This options name.
  late final String name;

  /// This options int value. If there is an int value there can't be a [SlashArgChoice.stringValue]
  late final int? intValue;

  /// This options string value. If there is an string value there can't be a [SlashArgChoice.intValue]
  late final String? stringValue;

  /// A Choice for the user to input in int & string args. You can only have an int or string option.
  SlashArgChoice(this.name, {this.intValue, this.stringValue}) {
    if(this.intValue != null && this.stringValue != null) {
      throw SlashArgMisconfiguration._new("stringValue & intValue");
    }
    if(this.intValue == null && this.stringValue == null) {
      throw "MissingArgError: All SlashArgChoice need an int or string value";
    }
    if(this.name.length > 100) {
      throw ArgLength._new("SlashArgChoice.name", "1", "100");
    }
  }

  Map<String, dynamic> _build() => {
    "name": this.name,
    "value": this.stringValue ?? this.intValue
  };
}
