import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:omjh/main.dart' as main;

class ApiHelper {
  final String _baseUrl = 'http://127.0.0.1:3000/';

  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(_baseUrl + url));
    return _returnResponse(response);
  }

  Future<dynamic> post(String url, dynamic body) async {
    final response = await http.post(Uri.parse(_baseUrl + url), body: body);
    return _returnResponse(response);
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 401:
        main.navigatorKey.currentState?.pushNamedAndRemoveUntil('login', (Route<dynamic> route) => false);
        return null;
      default:
        return null;
    }
  }
}
