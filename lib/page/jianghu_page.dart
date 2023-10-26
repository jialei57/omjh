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
      // color: Colors.white,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/image/ic_shancun.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
          ),
        ),
      child: const Column(
        children: [Expanded(child: InfoBox()), ChatBox()],
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
