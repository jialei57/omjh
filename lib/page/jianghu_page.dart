import 'package:flutter/material.dart';
import 'package:omjh/page/chat_box.dart';
import 'package:omjh/page/info_box.dart';

class JiangHuPage extends StatelessWidget {
  const JiangHuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: const [Expanded(child: InfoBox()), ChatBox()],
      ),
    );
  }
}
