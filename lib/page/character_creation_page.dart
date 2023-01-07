import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omjh/bloc/character_creation_bloc.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';
import 'package:omjh/page/home_page.dart';

class CharacterCreationPage extends StatefulWidget {
  const CharacterCreationPage({super.key});

  @override
  State<CharacterCreationPage> createState() => _CharacterCreationPageState();
}

class _CharacterCreationPageState extends State<CharacterCreationPage> {
  int _step = 0;
  final int maxStep = 5;
  final CharacterCreationBloc _bloc = CharacterCreationBloc();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 43, 43, 43),
        child: Column(children: [
          Container(
            width: 250.0,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: DefaultTextStyle(
                style: ThemeStyle.textStyle
                    .copyWith(color: Colors.white, fontSize: 18),
                child: _buildStaticText()),
          ),
          SizedBox(
            width: 250.0,
            child: _buildContent(),
          )
        ]),
      ),
    );
  }

  Widget _buildContent() {
    if (_step == 1) {
      return _buildSexChoiceButton();
    }

    if (_step == 3) {
      return _buildNameInput();
    }

    if (_step == 5) {
      return _buildStartButton();
    }

    return _buildAnimatedText();
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        Get.offAll(() => const HomePage());
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 40,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2)),
            child: Center(
                child: Text('start'.tr,
                    style: ThemeStyle.textStyle
                        .copyWith(fontSize: 18, color: Colors.black))),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticText() {
    if (_step == 1 || _step == 2) {
      return Text('\n${'you_are_14'.tr}${getSex(_bloc.sex)}',
          style:
              ThemeStyle.textStyle.copyWith(color: Colors.white, fontSize: 18));
    }
    if (_step == 3 || _step == 4) {
      String name = _bloc.name;
      if (name.isNotEmpty) {
        name = '$name.';
      }
      return Text(
          '\n${'you_are_14'.tr}${getSex(_bloc.sex)}\n${'you_are_orphan'.tr}$name',
          style:
              ThemeStyle.textStyle.copyWith(color: Colors.white, fontSize: 18));
    }
    if (_step == 5) {
      String name = _bloc.name;
      if (name.isNotEmpty) {
        name = '$name.';
      }
      return Text(
          '\n${'you_are_14'.tr}${getSex(_bloc.sex)}\n${'you_are_orphan'.tr}$name\n${'your_journey_begins'.tr}',
          style:
              ThemeStyle.textStyle.copyWith(color: Colors.white, fontSize: 18));
    }

    return const SizedBox.shrink();
  }

  Widget _buildAnimatedText() {
    return DefaultTextStyle(
      style: ThemeStyle.textStyle.copyWith(color: Colors.white, fontSize: 18),
      child: AnimatedTextKit(
        key: UniqueKey(),
        animatedTexts: [
          TyperAnimatedText(_getAnimatedText(),
              speed: const Duration(milliseconds: 150)),
        ],
        isRepeatingAnimation: false,
        onFinished: () {
          if (_step < maxStep) {
            setState(() {
              _step += 1;
            });
          }
        },
      ),
    );
  }

  String getSex(String sex) {
    if (sex == 'm') {
      return '${'boy'.tr}.';
    } else if (sex == 'f') {
      return '${'girl'.tr}.';
    }

    return '';
  }

  String _getAnimatedText() {
    const String buffer = '            \n';
    switch (_step) {
      case 0:
        return '$buffer${'you_are_14'.tr}';
      case 2:
        return 'you_are_orphan'.tr;
      case 4:
        return 'your_journey_begins'.tr;
      default:
        return '';
    }
  }

  bool validteName() {
    final name = _nameController.text;
    if (name.length < 2) {
      Get.rawSnackbar(message: 'name_too_short'.tr);
      return false;
    }
    // RegExp reg = RegExp("[ A-Za-z\u3000-\u303F\u3400-\u4DBF\u4E00-\u9FFF]");
    RegExp reg = RegExp(r'^[a-zA-Z \u3000-\u303F\u3400-\u4DBF\u4E00-\u9FFF]+$');

    if (!reg.hasMatch(name)) {
      Get.rawSnackbar(message: 'name_not_allowed'.tr);
      return false;
    }

    return true;
  }

  Widget _buildNameInput() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 0),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
            style: ThemeStyle.textStyle
                .copyWith(fontSize: 18, color: Colors.white),
            cursorColor: Colors.white,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              FilteringTextInputFormatter.allow(RegExp(
                  r'^[a-zA-Z \u3000-\u303F\u3400-\u4DBF\u4E00-\u9FFF]+$'))
            ],
            controller: _nameController,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              createCharacter();
            },
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2)),
              child: Center(
                  child: Text('确认',
                      style: ThemeStyle.textStyle
                          .copyWith(fontSize: 18, color: Colors.black))),
            ),
          ),
        ],
      ),
    );
  }

  void createCharacter() async {
    if (validteName()) {
      _bloc.name = _nameController.text;
      bool success = await _bloc.createCharacter();
      if (success) {
        setState(() {
          _step += 1;
        });
      }
    }
  }

  Widget _buildSexChoiceButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _bloc.sex = 'm';
              setState(() {
                _step = 2;
              });
            },
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2)),
              child: Center(
                  child: Text('boy'.tr,
                      style: ThemeStyle.textStyle
                          .copyWith(fontSize: 18, color: Colors.black))),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              _bloc.sex = 'f';
              setState(() {
                _step += 1;
              });
            },
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2)),
              child: Center(
                  child: Text('girl'.tr,
                      style: ThemeStyle.textStyle
                          .copyWith(fontSize: 18, color: Colors.black))),
            ),
          )
        ],
      ),
    );
  }
}
