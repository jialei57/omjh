import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/splash_bloc.dart';
import 'package:omjh/common/app_translation.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/page/character_creation_page.dart';
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
  Shared shared = Get.put(Shared());
  double _step = 0;
  final _maxSteps = 4.0;
  final _iconSize = 40.0;
  final _progressPadding = 40.0;

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

    setState(() {
      _step++;
    });

    bool mapDownloaded = await _bloc.getMap();
    if (!mapDownloaded) {
      Get.rawSnackbar(message: 'Download map failed.');
      return;
    }

    await shared.loadMap();

    setState(() {
      _step++;
    });

    List<Character>? chars = await _bloc.getCharacters();
    if (chars == null) {
      return;
    }

    setState(() {
      _step++;
    });

    if (chars.isEmpty) {
      Get.offAll(() => const CharacterCreationPage());
      return;
    }

    shared.characters = chars;
    await shared.init();

    shared.quests = await _bloc.getQuests(shared.currentCharacter!.id!) ?? [];

    setState(() {
      _step++;
    });

    Get.offAll(() => const HomePage());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    shared.contentHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(image: AssetImage('assets/image/ic_splash.png')),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Spacer(),
        LayoutBuilder(builder: (context, constrains) {
          var leftPadding =
              (constrains.maxWidth - 2 * _progressPadding) * _step / _maxSteps +
                  _iconSize / 2;
          return Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: Image(
                image:
                    const AssetImage('assets/image/ic_progress_indicator.png'),
                width: _iconSize,
                height: _iconSize,
              ));
        }),
        Padding(
          padding:
              EdgeInsets.fromLTRB(_progressPadding, 0, _progressPadding, 100),
          child: LinearProgressIndicator(
              value: _step / _maxSteps,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.grey,
              minHeight: 10),
        ),
      ]),
    ));
  }
}
