import 'package:nyxx/src/typedefs.dart';

abstract class IHttpErrorData {
  /// The error code.
  ///
  /// You can find a full list of these [here](https://discord.com/developers/docs/topics/opcodes-and-status-codes#json).
  int get errorCode;

  /// A human-readable description of the error represented by [errorCode].
  String get errorMessage;

  /// A mapping of field path to field error.
  ///
  /// Will be empty if Discord did not send any errors associated with specific fields in the request.
  Map<String, IFieldError> get fieldErrors;
}

class HttpErrorData implements IHttpErrorData {
  @override
  final int errorCode;

  @override
  final String errorMessage;

  @override
  final Map<String, FieldError> fieldErrors = {};

  HttpErrorData(RawApiMap raw)
      : errorCode = raw['code'] as int,
        errorMessage = raw['message'] as String {
    final errors = raw['errors'] as RawApiMap?;

    if (errors != null) {
      _initErrors(errors);
    }
  }

  void _initErrors(RawApiMap fields, [List<String> path = const []]) {
    final errors = fields['_errors'] as RawApiList?;

    if (errors != null) {
      for (final error in errors.cast<RawApiMap>()) {
        final fieldError = FieldError(
          path: path,
          errorCode: error['code'] as String,
          errorMessage: error['message'] as String,
        );

        fieldErrors[fieldError.name] = fieldError;
      }
    }

    for (final nestedElement in fields.entries) {
      if (nestedElement.value is! RawApiMap) {
        continue;
      }

      _initErrors(nestedElement.value as RawApiMap, [...path, nestedElement.key]);
    }
  }
}

abstract class IFieldError {
  /// A human-readable name of this field.
  String get name;

  /// The segments of the path to this field in the request.
  List<String> get path;

  /// The error code.
  String get errorCode;

  /// A human-readable description of the error represented by [errorCode].
  String get errorMessage;
}

class FieldError implements IFieldError {
  @override
  final String name;

  @override
  final List<String> path;

  @override
  final String errorCode;

  @override
  final String errorMessage;

  FieldError({
    required this.path,
    required this.errorCode,
    required this.errorMessage,
  }) : name = pathToName(path);

  static String pathToName(List<String> path) {
    if (path.isEmpty) {
      return '';
    }

    final result = StringBuffer(path.first);

    for (final part in path.skip(1)) {
      final isArrayIndex = RegExp(r'^\d+$').hasMatch(part);

      if (isArrayIndex) {
        result.write('[$part]');
      } else {
        result.write('.$part');
      }
    }

    return result.toString();
  }
}
