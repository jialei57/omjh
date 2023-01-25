import 'package:flutter/material.dart';
import 'package:omjh/page/chat_box.dart';
import 'package:omjh/page/info_box.dart';

class JiangHuPage extends StatefulWidget {
  const JiangHuPage({super.key});

  @override
  State<JiangHuPage> createState() => _JiangHuPageState();
}

class _JiangHuPageState extends State<JiangHuPage> with AutomaticKeepAliveClientMixin<JiangHuPage>{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: Column(
        children: const [Expanded(child: InfoBox()), ChatBox()],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
