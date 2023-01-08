import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:omjh/common/common.dart';
import 'dart:convert';
import 'dart:async';
import 'package:omjh/page/login_page.dart';

class ApiHelper {
  Map<String, String> headers = {};

  String getBaseURL() {
    return 'http://${Common.baseIP}/';
  }

  Future prepareHeaders({String contentType = 'application/json'}) async {
    headers[HttpHeaders.contentTypeHeader] = contentType;
    const storage = FlutterSecureStorage();
    String token = await storage.read(key: Common.authendicationToken) ?? '';
    headers[HttpHeaders.authorizationHeader] = token;
  }

  Future<dynamic> get(String url,
      {String contentType = 'application/json'}) async {
    await prepareHeaders(contentType: contentType);
    final response = await http.get(
      Uri.parse(getBaseURL()  + url),
      headers: headers,
    );
    return _returnResponse(response);
  }

  Future<dynamic> post(String url, dynamic body) async {
    await prepareHeaders();
    final response = await http.post(Uri.parse(getBaseURL()  + url),
        headers: headers, body: body);
    return _returnResponse(response);
  }

  Future<dynamic> put(String url, dynamic body) async {
    await prepareHeaders();
    final response = await http.put(Uri.parse(getBaseURL()  + url),
        headers: headers, body: body);
    return _returnResponse(response);
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        final String? responseContentType =
            response.request?.headers[HttpHeaders.contentTypeHeader];
        if (responseContentType != null &&
            responseContentType.contains('application/json')) {
          var responseJson = json.decode(response.body.toString());
          return responseJson;
        }

        return response.body.toString();
      case 401:
        if (response.request?.url.toString() ==
            '${getBaseURL() }authenticate') {
          Get.rawSnackbar(message: 'Wrong user name or password.');
          return null;
        }

        Get.offAll(() => const LoginPage());
        return null;
      case 404:
        Get.offAll(() => const LoginPage());
        return null;
      default:
        Get.rawSnackbar(message: response.body.toString());
        return null;
    }
  }
}
