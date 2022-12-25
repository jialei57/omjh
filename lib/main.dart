import 'package:flutter/material.dart';
import 'package:omjh/bloc/splash_bloc.dart';
import 'package:omjh/page/login_page.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Man Jiang Hu',
        navigatorKey: navigatorKey,
        theme:
            ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.black54),
        home: const SplashPage(),
        routes: {'login': (context) => const LoginPage()});
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashBloc _bloc = SplashBloc();

  @override
  void initState() {
    super.initState();
    //_bloc.getVersion();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
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
