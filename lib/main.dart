import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/splash_bloc.dart';
import 'package:omjh/common/app_translation.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/page/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(GetMaterialApp(
    home: const MyApp(),
    translations: AppTranslation(),
    locale: const Locale('zh', 'CN'),
    fallbackLocale: const Locale('zh', 'CN'),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Man Jiang Hu',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: ThemeStyle.bgColor),
        home: const SplashPage());
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
    checkVersion();
  }

  void checkVersion() async {
    int minVersion = await _bloc.getVersion();
    if (minVersion == 0) return;
    PackageInfo info = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(info.buildNumber);
    if (currentVersion < minVersion) {
      Get.rawSnackbar(message: 'Please update to latest version to continute.');
      return;
    }

    Get.offAll(const HomePage());
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
