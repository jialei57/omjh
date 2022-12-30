import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/splash_bloc.dart';
import 'package:omjh/common/app_translation.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/spot.dart';
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
            primarySwatch: Colors.blue, primaryColor: ThemeStyle.bgColor),
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
    prepare();
  }

  void prepare() async {
    int minVersion = await _bloc.getVersion();
    if (minVersion == 0) return;
    PackageInfo info = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(info.buildNumber);
    if (currentVersion < minVersion) {
      Get.rawSnackbar(message: 'Please update to latest version to continute.');
      return;
    }

    List<Character>? chars = await _bloc.getCharacters();
    if (chars == null) {
      return;
    }

    if (chars.isEmpty) {
      return; // to be implemented
    }

    int currentCharIndex = 0;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? currentCharIndexString =
        await storage.read(key: Common.currentCharacterIndex);
    if (currentCharIndexString == null) {
      await storage.write(key: Common.currentCharacterIndex, value: '0');
    }

    Shared shared = Get.put(Shared());
    shared.currentCharacter = chars[currentCharIndex];

    List<Spot>? maps = await _bloc.getCurrentCityMaps();
    if (maps == null || maps.isEmpty) {
      return; // to be implemented
    }

    shared.currentMaps = maps;
    shared.currentMap = maps.firstWhereOrNull(
        (element) => element.id == shared.currentCharacter?.map);

    Get.offAll(() => const HomePage());
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
