part of nyxx.commands;

class _CommandMetadata {
  MethodMirror method;
  ObjectMirror parent;

  Restrict classRestrict;
  Module classCommand;

  Restrict methodRestrict;
  Command methodCommand;

  List<Preprocessor> preprocessors;
  List<Postprocessor> postprocessors;

  Help methodHelp;

  _CommandMetadata(
      this.method,
      this.parent,
      this.classRestrict,
      this.classCommand,
      this.methodCommand,
      this.methodRestrict,
      this.methodHelp,
      [this.preprocessors = const [],
      this.postprocessors = const []]);

  List<List<String>> get commandString {
    if (classCommand != null) if (methodCommand.name == null &&
        methodCommand.main)
      return [List.from(classCommand.aliases)..add(classCommand.name)];
    else
      return [
        List.from(classCommand.aliases)..add(classCommand.name),
        List.from(methodCommand.aliases)..add(methodCommand.name)
      ];

    return [List.from(methodCommand.aliases)..add(methodCommand.name)];
  }
}
