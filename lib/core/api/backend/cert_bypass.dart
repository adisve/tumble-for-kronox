import 'dart:async';
import 'dart:io';
import 'dart:convert';

class HttpService {
  static Future<HttpClientResponse?> sendGetRequestToServer(Uri url, {Map<String, String>? headers}) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      HttpClientRequest request = await client.getUrl(url).timeout(const Duration(seconds: 10));
      if (headers != null) {
        for (MapEntry pair in headers.entries) {
          request.headers.add(pair.key, pair.value);
        }
      }
      return await request.close();
    } on Exception {
      return null;
    }
  }

  static Future<HttpClientResponse?> sendPostRequestToServer(Uri url, String body) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      HttpClientRequest request = await client.postUrl(url).timeout(const Duration(seconds: 10));
      request.headers.add("Content-Type", "application/json; charset=UTF-8");
      request.add(utf8.encode(body));
      return await request.close();
    } on Exception {
      return null;
    }
  }

  static Future<HttpClientResponse?> sendPutRequestToServer(Uri url, {String? body}) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      HttpClientRequest request = await client.putUrl(url).timeout(const Duration(seconds: 10));
      request.headers.add("Content-Type", "application/json; charset=UTF-8");
      if (body != null) request.add(utf8.encode(body));
      return await request.close();
    } on Exception {
      return null;
    }
  }
}
