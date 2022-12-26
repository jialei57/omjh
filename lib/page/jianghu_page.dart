import 'package:flutter/material.dart';
import 'package:omjh/page/chat_box.dart';

class JiangHuPage extends StatelessWidget {
  const JiangHuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Container()),
        const ChatBox()
      ],
    );
  }
}
