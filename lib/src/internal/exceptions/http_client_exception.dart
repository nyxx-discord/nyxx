import 'package:http/http.dart' as http;

/// Exception of http client
@Deprecated('Unused, will be removed in the next major release')
class HttpClientException extends http.ClientException {
  /// Raw response from server
  final http.BaseResponse? response;

  // ignore: public_member_api_docs
  HttpClientException(this.response) : super("Exception", response?.request?.url);
}
