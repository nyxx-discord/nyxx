import 'dart:convert';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:nyxx/nyxx.dart';
import 'package:test/test.dart';

import '../../mocks/request.dart';
import '../../mocks/response.dart';

void main() {
  group('HttpResponseSuccess', () {
    test('has correct body', () {
      final mockHttpResponse = MockPackageHttpResponse();
      when(() => mockHttpResponse.statusCode).thenReturn(200);
      when(() => mockHttpResponse.headers).thenReturn({});

      final response = HttpResponseSuccess(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList(utf8.encode(jsonEncode({'value': 'test body'}))),
      );

      expect(response.textBody, equals(r'{"value":"test body"}'));
      expect(response.hasJsonBody, isTrue);
      expect(response.jsonBody, equals({'value': 'test body'}));
    });

    test('handles invalid bodies', () {
      final mockHttpResponse = MockPackageHttpResponse();
      when(() => mockHttpResponse.statusCode).thenReturn(200);
      when(() => mockHttpResponse.headers).thenReturn({});

      final response = HttpResponseSuccess(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList(utf8.encode('some invalid json')),
      );

      expect(response.textBody, equals('some invalid json'));
      expect(response.hasJsonBody, isFalse);
      expect(response.jsonBody, isNull);
    });
  });

  group('HttpResponseError', () {
    test('has correct body', () {
      final mockHttpResponse = MockPackageHttpResponse();
      when(() => mockHttpResponse.statusCode).thenReturn(400);
      when(() => mockHttpResponse.headers).thenReturn({});

      final response = HttpResponseSuccess(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList(utf8.encode(jsonEncode({'value': 'test body'}))),
      );

      expect(response.textBody, equals(r'{"value":"test body"}'));
      expect(response.hasJsonBody, isTrue);
      expect(response.jsonBody, equals({'value': 'test body'}));
    });

    test('handles invalid bodies', () {
      final mockHttpResponse = MockPackageHttpResponse();
      when(() => mockHttpResponse.statusCode).thenReturn(400);
      when(() => mockHttpResponse.headers).thenReturn({});

      final response = HttpResponseSuccess(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList(utf8.encode('some invalid json')),
      );

      expect(response.textBody, equals('some invalid json'));
      expect(response.hasJsonBody, isFalse);
      expect(response.jsonBody, isNull);
    });

    test('has correct error code', () {
      final mockHttpResponse = MockPackageHttpResponse();
      when(() => mockHttpResponse.statusCode).thenReturn(400);
      when(() => mockHttpResponse.headers).thenReturn({});

      final response = HttpResponseError(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList(utf8.encode(jsonEncode({
          'code': 1001,
          'message': 'A dummy message',
        }))),
      );

      expect(response.errorCode, equals(1001));
      expect(response.message, equals('A dummy message'));

      final response2 = HttpResponseError(
        response: mockHttpResponse,
        request: MockHttpRequest(),
        body: Uint8List.fromList([]),
      );

      // 400 is the status code we set in the mock above
      expect(response2.errorCode, equals(400));
    });
  });

  group('FieldError', () {
    test('pathToName', () {
      expect(FieldError.pathToName([]), equals(''));
      expect(FieldError.pathToName(['foo']), equals('foo'));
      expect(FieldError.pathToName(['foo', 'bar']), equals('foo.bar'));
      expect(FieldError.pathToName(['foo', '175', 'bar']), equals('foo[175].bar'));
      expect(FieldError.pathToName(['foo', '175', '80', 'bar']), equals('foo[175][80].bar'));
    });
  });

  group('HttpErrorData', () {
    test('throws TypeError on invalid input', () {
      expect(() => HttpErrorData.parse({'some': 'invalid', 'input': '80'}), throwsA(isA<TypeError>()));
      expect(() => HttpErrorData.parse({'code': 'invalid', 'message': '80'}), throwsA(isA<TypeError>()));
    });

    test('parses error messages correctly', () {
      final errorData = HttpErrorData.parse({
        "code": 50035,
        "errors": {
          "activities": {
            "0": {
              "platform": {
                "_errors": [
                  {"code": "BASE_TYPE_CHOICES", "message": "Value must be one of ('desktop', 'android', 'ios')."}
                ]
              },
              "type": {
                "_errors": [
                  {"code": "BASE_TYPE_CHOICES", "message": "Value must be one of (0, 1, 2, 3, 4, 5)."}
                ]
              }
            }
          }
        },
        "message": "Invalid Form Body"
      });

      expect(errorData.errorCode, equals(50035));
      expect(errorData.errorMessage, equals('Invalid Form Body'));
      expect(errorData.fieldErrors.length, equals(2));

      expect(errorData.fieldErrors['activities[0].platform']?.errorCode, equals('BASE_TYPE_CHOICES'));
      expect(errorData.fieldErrors['activities[0].type']?.errorMessage, equals('Value must be one of (0, 1, 2, 3, 4, 5).'));
    });
  });
}
