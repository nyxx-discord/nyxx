part of nyxx.commands;

class _CommandMetadata {
  MethodMirror method;
  ObjectMirror parent;

  Module parentCommand;
  Command methodCommand;

  Restrict restrict;

  List<Preprocessor> preprocessors;
  List<Postprocessor> postprocessors;

  List<List<String>> commandString;

  _CommandMetadata(
      this.commandString,
      this.method,
      this.parent,
      this.parentCommand,
      this.methodCommand,
      this.restrict,
      [this.preprocessors = const [],
      this.postprocessors = const []]);
}
