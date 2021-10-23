import 'package:http/http.dart' as http;

import 'package:logging/logging.dart';
import 'package:nyxx/src/Nyxx.dart';
import 'package:nyxx/src/internal/http/HttpBucket.dart';
import 'package:nyxx/src/internal/http/HttpClient.dart';
import 'package:nyxx/src/internal/http/HttpRequest.dart';
import 'package:nyxx/src/internal/http/HttpResponse.dart';

class HttpHandler {
  final RegExp _bucketRegexp = RegExp(r"\/(channels|guilds)\/(\d+)");
  final RegExp _bucketReactionsRegexp =
      RegExp(r"\/channels/(\d+)\/messages\/(\d+)\/reactions");
  final RegExp _bucketCommandPermissions =
      RegExp(r"\/applications/(\d+)\/guilds\/(\d+)\/commands/permissions");

  final List<HttpBucket> _buckets = [];
  late final HttpBucket _noRateBucket;

  late final InternalHttpClient _httpClient;

  final Logger logger = Logger("Http");
  final NyxxRest client;

  /// Creates an instance of [HttpHandler]
  HttpHandler(this.client) {
    this._noRateBucket = HttpBucket("", this);
    this._httpClient = InternalHttpClient(client.token);
  }

  Future<HttpResponse> execute(HttpRequest request) async {
    request.passClient(this._httpClient);

    if (!request.rateLimit) {
      return _handle(await this._noRateBucket.execute(request));
    }

    final bucket = this._getBucketForRequest(request);
    return _handle(await bucket.execute(request));
  }

  HttpBucket _getBucketForRequest(HttpRequest request) {
    final reactionsRegexMatch =
        _bucketReactionsRegexp.firstMatch(request.uri.toString());
    if (reactionsRegexMatch != null) {
      final bucketMajorId = reactionsRegexMatch.group(1);
      final bucketMessageId = reactionsRegexMatch.group(2);

      return this._findBucketById("reactions/$bucketMajorId/$bucketMessageId");
    }

    final commandPermissionRegexMatch =
        _bucketCommandPermissions.firstMatch(request.uri.toString());

    if (commandPermissionRegexMatch != null) {
      final bucketMajorId = commandPermissionRegexMatch.group(1);
      final bucketMessageId = commandPermissionRegexMatch.group(2);

      return this._findBucketById("commands/permissions/$bucketMajorId/$bucketMessageId");
    }

    final bucketRegexMatch = _bucketRegexp.firstMatch(request.uri.toString());
    late String bucketId;

    if (bucketRegexMatch == null) {
      bucketId = request.uri.toString();
    } else {
      final bucketName = bucketRegexMatch.group(1);
      final bucketMajorId = bucketRegexMatch.group(2);
      bucketId = "${request.method}/$bucketName/$bucketMajorId";
    }

    return this._findBucketById(bucketId);
  }

  HttpBucket _findBucketById(String bucketId) {
    try {
      return _buckets.firstWhere((element) => element.id == bucketId);
    } on StateError {
      final newBucket = HttpBucket(bucketId, this);
      _buckets.add(newBucket);

      return newBucket;
    }
  }

  Future<HttpResponse> _handle(http.StreamedResponse response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseSuccess = HttpResponseSuccess(response);
      await responseSuccess.finalize();

      // TODO: fix this
      // _client._onHttpResponse.add(HttpResponseEvent._new(responseSuccess));

      this.logger.finer("Got successful http response for endpoint: [${response.request?.url.toString()}]; Response: [${responseSuccess.jsonBody}]");

      return responseSuccess;
    }

    final responseError = HttpResponseError(response);
    await responseError.finalize();

    // TODO: fix this
    // _client._onHttpError.add(HttpErrorEvent._new(responseError));

    this.logger.finer("Got failure http response for endpoint: [${response.request?.url.toString()}]; Response: [${responseError.errorMessage}]");

    return responseError;
  }
}
