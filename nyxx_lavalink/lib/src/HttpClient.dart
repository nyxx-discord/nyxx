part of nyxx_lavalink;

class _HttpClient extends http.BaseClient {
  late final Map<String, String> defaultHeaders;
  final http.Client _innerClient = http.Client();

  _HttpClient(NodeOptions options) {
    this.defaultHeaders = {
      "Authorization": options.password,
      "Num-Shards": options.shards.toString(),
      "User-Id": options.clientId.toString()
    };
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(this.defaultHeaders);

    final response = await this._innerClient.send(request);

    if (response.statusCode >= 400) {
      throw http.ClientException(response.toString());
    }

    return response;
  }
}