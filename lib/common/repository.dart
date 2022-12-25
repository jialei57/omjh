import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:omjh/common/api_helper.dart';
import 'package:omjh/common/common.dart';

class Repository {
  final ApiHelper _helper = ApiHelper();
  Future<int> getVersion() async {
    try {
      final jsonData = await _helper.get('mobile-app-version');
      if (jsonData == null) {
        return 0;
      }

      return jsonData['version'];
    } on SocketException {
      // Fluttertoast.showToast(
      //     msg: 'Connection failed',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     backgroundColor: Colors.grey,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
    return 0;
  }

  Future<String?> authenticate(String username, String password) async {
    try {
      final jsonData = await _helper.post(
          'authenticate', '{"username":$username,"password":$password}');
      if (jsonData == null) {
        return null;
      }

      final String token = jsonData['auth_token'];
      const storage = FlutterSecureStorage();
      await storage.write(key: Common.authendicationToken, value: token);

      return token;
    } on SocketException {
      // Fluttertoast.showToast(
      //     msg: 'Connection failed',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     backgroundColor: Colors.grey,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
    return null;
  }
}
