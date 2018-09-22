import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Sends regular request. Returns decoded message body
Future<dynamic> sendRequest(String method, Uri uri,
    {dynamic body, Map<String, String> headers}) async {
  var req = http.Request(method, uri);

  if (body != null) req.body = jsonEncode(body);
  if (headers != null) req.headers.addAll(headers);

  var r = await req.send();
  var res = await r.stream.bytesToString();

  try {
    return jsonDecode(res);
  } on FormatException {
    return null;
  }
}

/// Sends multipart request. Returns decoded message body
Future<dynamic> sendMultipart(String method, Uri uri,
    {List<File> files,
    Map<String, String> fields,
    Map<String, String> headers}) async {
  var req = http.MultipartRequest(method, uri);
  if (headers != null) req.headers.addAll(headers);
  if (fields != null) req.fields.addAll(fields);

  if (files != null) {
    for (var file in files) {
      var name = Uri.file(file.path).toString().split("/").last;
      var s = await file.readAsBytes();

      req.files.add(http.MultipartFile.fromBytes(name, s, filename: name));
    }
  }

  var r = await req.send();
  var res = await r.stream.bytesToString();

  try {
    return jsonDecode(res);
  } on FormatException {
    return null;
  }
}

/// Just download file. Returns bytes of response body
Future<List<int>> downloadFile(Uri uri) async {
  var req = await http.get(uri);
  return req.bodyBytes;
}
