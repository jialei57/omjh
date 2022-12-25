import 'dart:async';

import 'package:flutter/material.dart';
import 'package:omjh/page/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Man Jiang Hu',
      theme:
          ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.black54),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer.run(() {
          Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
      color: Colors.white,
      image: DecorationImage(image: AssetImage('assets/image/ic_splash.png')),
    )));
  }
}
