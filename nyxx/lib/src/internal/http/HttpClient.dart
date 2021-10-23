import 'package:http/http.dart' as http;
import 'package:nyxx/src/internal/exceptions/HttpClientException.dart';

class InternalHttpClient extends http.BaseClient {
  late final Map<String, String> _authHeader;

  final http.Client _innerClient = http.Client();

  // ignore: public_member_api_docs
  InternalHttpClient(String token) {
    this._authHeader = {
      "Authorization" : "Bot $token"
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
