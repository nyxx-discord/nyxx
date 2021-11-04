part of nyxx;

/// Exception of http client
class HttpClientException extends http.ClientException {
  /// Raw response from server
  final http.BaseResponse? response;

  // ignore: public_member_api_docs
  HttpClientException(this.response) : super("Exception", response?.request?.url);
}
