part of nyxx;

class DownloadUtils {
  /// Downloads file. Returns bytes of response body
  static Future<List<int>> downloadFile(Uri uri) async {
    var req = transport.Request()..uri = uri;

    return (await req.send("GET")).body.asBytes();
  }
}