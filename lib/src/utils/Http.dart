import 'package:w_transport/w_transport.dart';

import 'dart:async';
import 'dart:io';

/// Sends regular request. Returns json decoded message body
Future<dynamic> sendRequest(String method, Uri uri,
    {dynamic body, Map<String, String> headers}) async {
  var req = JsonRequest()
    ..uri = uri;

  if(headers != null) req.headers = headers;
  if(body != null) req.body = body;

  var r = await req.send(method);
  return r.body.asJson();
}

/// Sends multipart request. Returns decoded message body
Future<dynamic> sendMultipart(String method, Uri uri,
    {List<File> files,
    Map<String, String> fields,
    Map<String, String> headers}) async {

  var req = MultipartRequest()
    ..uri = uri;

  if(headers != null) req.headers = headers;
  if(fields != null) req.fields = headers;

  if (files != null) {
    for (var file in files) {
      var name = Uri.file(file.path).toString().split("/").last;
      req.files[name] = MultipartFile(file.readAsBytes().asStream(), file.lengthSync(), filename: name);
    }
  }

  var r = await req.send(method);
  return r.body.asJson();
}

/// Just download file. Returns bytes of response body
Future<List<int>> downloadFile(Uri uri) async {
  var req = Request()
    ..uri = uri;

  return (await req.send("GET")).body.asBytes();
}