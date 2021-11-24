class UnrecoverableNyxxError implements Error {
  final String message;

  UnrecoverableNyxxError(this.message);

  @override
  StackTrace? get stackTrace => StackTrace.current;

  @override
  String toString() => "UnrecoverableNyxxError: $message";
}
