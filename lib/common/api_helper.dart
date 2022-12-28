import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:omjh/common/common.dart';
import 'dart:convert';
import 'dart:async';
import 'package:omjh/page/login_page.dart';

class ApiHelper {
  final String _baseUrl = 'http://127.0.0.1:3000/';
  Map<String, String> headers = {};

  Future prepareHeaders() async {
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    const storage = FlutterSecureStorage();
    String token = await storage.read(key: Common.authendicationToken) ?? '';
    headers[HttpHeaders.authorizationHeader] = token;
  }

  Future<dynamic> get(String url) async {
    await prepareHeaders();
    final response = await http.get(
      Uri.parse(_baseUrl + url),
      headers: headers,
    );
    return _returnResponse(response);
  }

  Future<dynamic> post(String url, dynamic body) async {
    await prepareHeaders();
    final response = await http.post(Uri.parse(_baseUrl + url),
        headers: headers, body: body);
    return _returnResponse(response);
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 401:
        if (response.request?.url.toString() == '${_baseUrl}authenticate') {
          Get.rawSnackbar(message: 'Wrong user name or password.');
          return null;
        }

        Get.offAll(()=> const LoginPage());
        return null;
      case 404:
        Get.offAll(()=> const LoginPage());
        return null;
      default:
        return null;
    }
  }
}
