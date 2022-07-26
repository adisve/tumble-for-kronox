import 'dart:io';
import 'dart:convert';

import 'package:tumble/models/api_models/program_model.dart';

class HttpService {
  static Future<HttpClientResponse> sendRequestToServer(Uri url) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await client.getUrl(url);
    return await request.close();
  }
}
