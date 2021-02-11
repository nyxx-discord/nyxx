part of nyxx;

class _HttpClient extends http.BaseClient {
  late final Map<String, String> _authHeader;

  final http.Client _innerClient = http.Client();

  // ignore: public_member_api_docs
  _HttpClient(Nyxx client) {
    this._authHeader = {
      "Authorization" : "Bot ${client._token}"
    };
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(this._authHeader);
    final response = await this._innerClient.send(request);

    if (response.statusCode >= 400) {
      throw HttpClientException(response);
    }

    return response;
  }
}
